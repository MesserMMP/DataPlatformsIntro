# 🐝 HW3: Hive Deployment (Non-Embedded)

## 📄 Description
This repository contains documentation and scripts to deploy Apache Hive 4.0.0-alpha-2 in a non-embedded mode with PostgreSQL as the metastore. It includes the steps for:
- Installing and configuring PostgreSQL
- Setting up Hive with proper configuration
- Loading sample data into a partitioned Hive table
- Verifying data load

## 📂 Structure
```
hw3-hive-deployment/
│
├── instructions.md         # Manual deployment instructions
├── README.md               # General overview
└── scripts/                # Automation scripts
    ├── 1_init_postgres.sh
    ├── 2_install_hive.sh
    ├── 3_setup_hive_env.sh
    ├── 4_start_hive.sh
    └── 5_load_sample_data.sh
```

## 🛠 Usage
You can follow either `instructions.md` for manual steps or run the automation scripts in order from the `scripts/` directory.
