# azure-webapp-iac

## 개요
해당 프로젝트는 **Terraform과 Bash 스크립트**를 사용하여 **Azure 웹 애플리케이션 인프라를 구축**하는 IaC(Infrastructure as Code) 프로젝트입니다.

- **사용 도구**: Terraform, Azure CLI
- **웹 서버**: WordPress (Apache)
- **데이터베이스**: MySQL (Primary/Secondary)
- **Azure 환경 설정**:
  - 단일 Subscription
  - Region: `centralus`
  - Resource Group: `rg-webapp-cus`
- **배포 방식**: Terraform + Bash 자동화
- **아키텍처 다이어그램**:
<img src="https://drive.google.com/thumbnail?id=1BQzPkRl9GCLe7ivZLnFOGEnTb5vO5Ha7&sz=w9000" style="max-width:100%; height:auto; border:1px solid gray;">

## 프로젝트 구조
```bash
# Terraform 모듈을 사용하지 않고, 리소스를 개별 `.tf` 파일로 나누어 구성함.
azure-webapp-iac
├── webapp-scripts/       # 웹 및 DB 서버 설정 자동화 스크립트
│   ├── db_primary.sh     # Primary DB 서버 설정 스크립트
│   ├── db_secondary.sh   # Secondary DB 서버 설정 스크립트
│   └── web.sh            # 웹 서버(Apache + WordPress) 설정 스크립트
├── basics.tf             # Provider, RG 설정
├── keyvault.tf           # Azure Key Vault 리소스 및 Secret 설정
├── lb.tf                 # Azure Load Balancer 설정
├── network.tf            # 네트워크 관련 리소스 설정 (VNet, 서브넷, NSG 등)
├── servers.tf            # 웹 및 DB 서버 설정
├── variables.tf          # Terraform 변수 정의
├── terraform.tfvars      # Terraform 변수 값 설정
└── readme.md             # 프로젝트 개요 및 사용 방법 문서
```

</br>

---

</br>
</br>

> 아래부터는 IAM 및 RBAC과 네트워크 구성을 중심으로 설정 방식을 설명합니다.

## 1️. IAM 설정 (Azure Entra ID - Service Principal)
Terraform이 Azure Key Vault에 접근하도록 Service Principal(SP)을 생성하고, 관련 역할 할당.

### **조건사항**
- Service Principal을 생성하려면 **Entra ID(Azure AD) 내 관리 권한 필요**  
- RBAC(Role-Based Access Control) 할당을 위해서는 **Azure Resource 수준의 관리 권한 필요**  

### **Terraform용 Service Principal 생성**
```bash
az ad sp create-for-rbac --name "terraform-sp" \
--role "Contributor" \
--scopes /subscriptions/XXXX-XXXX-XXXX-XXXX-XXXX
```
### **Key Vault 접근을 위한 RBAC 역할 할당**
테라폼이 RBAC 작업을 수행할 수 있도록 User Access Administrator 역할을 Service Principal에 할당 (최소 권한 원칙을 따라 Owner 대신에 User Access Administrator 역할 할당)

```bash
az role assignment create \
  --assignee <SERVICE_PRINCIPAL_ID> \
  --role "User Access Administrator" \
  --scope /subscriptions/XXXX-XXXX-XXXX-XXXX-XXXX/resourceGroups/rg-webapp-cus/providers/Microsoft.KeyVault/vaults/keyvault-cus
```

</br>


## 2. Network 구성
- **웹 서버 & DB 서버**: 프라이빗 서브넷에 배치 (인터넷 연결 필요 시 NAT Gateway 사용)
- **NSG(Network Security Group) Rule 설정**
  - Bastion: 22번 포트 (SSH)
  - Web 서버: 80번 포트 (HTTP)
  - DB 서버: 3306번 포트 (MySQL)
- **Public Load Balancer (LB)**
  - 웹 서버 2대에 부하 분산
  - 백엔드 풀에 웹 서버의 NIC 연결

## 3. Key vault
Terraform이 Key Vault에 접근하도록 SP에 적절한 권한 부여가 필요.

### **Key Vault 권한 할당 (Control Plane & Data Plane)**
- Control Plane(Key Vault 리소스 자체)과 Data Plane(Key Vault 데이터, Secret) 모두에 대해 기본적으로 권한이 없기 때문에, 두개 모두 할당.

```bash
# Key Vault 접근 권한
az role assignment create \
  --assignee <SERVICE_PRINCIPAL_ID> \
  --role "Key Vault Contributor" \
  --scope /subscriptions/XXXX-XXXX-XXXX-XXXX-XXXX/resourceGroups/rg-webapp-cus/providers/Microsoft.KeyVault/vaults/keyvault-cus

# Key Vault Secret 생성 및 삭제 권한
az role assignment create \
  --assignee <SERVICE_PRINCIPAL_ID> \
  --role "Key Vault Secrets Officer" \
  --scope /subscriptions/XXXX-XXXX-XXXX-XXXX-XXXX/resourceGroups/rg-webapp-cus/providers/Microsoft.KeyVault/vaults/keyvault-cus

# 역할 할당 확인
az role assignment list --assignee <SERVICE_PRINCIPAL_ID> --all --query '[].{Role:roleDefinitionName, Scope:scope}' -o table
```

### **DB 접속 정보를 Key Vault Secret으로 저장**
- Key Vault Secret 생성
```bash
resource "azurerm_key_vault_secret" "kv_secret" {
  name         = var.secret.name
  value        = var.secret.value
  key_vault_id = azurerm_key_vault.kv.id
}
```

## 4. Managed Identity
- VM이 System Assigned Identity를 부여받아 Key Vault Secret에 접근 가능하도록 설정
- VM이 Key Vault Secret을 읽을 수 있도록 역할 할당

```bash
# VM에 Vault 접근 권한 부여
resource "azurerm_linux_virtual_machine" "vm_web1" {
  # Managed Service Identity - Key vault
  identity {
    type = "SystemAssigned"
  }
}

# Role assignment
resource "azurerm_role_assignment" "kv_access_web1" {
  scope                = azurerm_key_vault.kv.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_linux_virtual_machine.vm_web1.identity[0].principal_id
}
```