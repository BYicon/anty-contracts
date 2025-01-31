# Anty Contract
NFT market


## env_enc 配置文件

`npx env-enc set-pw`

`npx env-enc set`


## 部署

### 可能需要先输入设置的env-enc密码，不需要忽略此步骤
`npx env-enc set-pw`

### 编译合约
`npx hardhat compile`

### 部署ERC20
`npx hardhat deploy-mir --network sepolia`

### 部署nft  --addr 是ERC20的地址
`npx hardhat deploy-nft --network sepolia --addr ${ERC20_ADDRESS}`

### 部署airdrop  --addr 是ERC20的地址
`npx hardhat deploy-airdrop --network sepolia --addr ${ERC20_ADDRESS}`


### 部署mock token
`npx hardhat deploy-mock --network sepolia`
