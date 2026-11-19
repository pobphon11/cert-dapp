# SkillTrust Academy · Blockchain Digital Certificate Verification System

ระบบออกและตรวจสอบใบรับรองดิจิทัลด้วย Ethereum Smart Contract (โจทย์ที่ 3)

🔗 **เว็บ DApp:** https://pobphon11.github.io/cert-dapp/

## สมาชิกกลุ่ม

| ลำดับ | รหัสนักศึกษา | ชื่อ-สกุล |
|:---:|:---:|---|
| 1 | 66002022 | คฑาวุธ เมืองพรหม |
| 2 | 66016519 | พบพร จิตโสภา |
| 3 | 66050180 | นพรัตน์ สวัสดิ์เอื้อ |
| 4 | 66050731 | อชิรยุ นวลสกลุวัฒน์ |
| 5 | 66031036 | ธนภัทร หนูบุญมี |

## ฟังก์ชันของระบบ

1. **ลงทะเบียนหลักสูตร (Create Training Course)**: ผู้ดูแลระบบสร้างหลักสูตร รหัสหลักสูตร และรายละเอียดการอบรม
2. **ออกใบรับรอง (Issue Certificate)**: ผู้ที่ได้รับสิทธิ์ออกใบรับรองพร้อมรหัสอ้างอิง วันที่ออก ข้อมูลผู้รับ และ QR Code
3. **บันทึกหลักฐานบน Blockchain (Store Certificate Hash)**: บันทึก hash ของข้อมูลใบรับรองเพื่อยืนยันว่าเอกสารไม่ถูกแก้ไข
4. **ตรวจสอบความถูกต้อง (Verify Certificate)**: ค้นหาด้วยรหัสใบรับรองหรือสแกน QR Code โดยไม่ต้องเชื่อม Wallet
5. **เพิกถอนใบรับรอง (Revoke Certificate)**: ผู้ได้รับสิทธิ์ยกเลิกใบรับรองได้ โดยประวัติการออกยังคงอยู่
6. **แสดงประวัติใบรับรอง (Certificate Dashboard)**: ผู้เข้าอบรมเชื่อม Wallet เพื่อดูใบรับรองที่ผูกกับบัญชีของตน

## กฎทางธุรกิจ

- รหัสใบรับรองต้องไม่ซ้ำกัน (contract ปฏิเสธรหัสซ้ำ)
- เฉพาะ Admin หรือ Issuer ที่ได้รับสิทธิ์เท่านั้นที่ออก/เพิกถอนใบรับรองได้
- ไม่บันทึกข้อมูลส่วนบุคคลบน Public Blockchain: ชื่อผู้รับเก็บนอก chain และบันทึกเฉพาะ hash ที่ผสม Verification Code (salt) เพื่อป้องกันการเดาชื่อจาก hash

## ข้อมูลทางเทคนิค

| รายการ | ค่า |
|---|---|
| Network | Ethereum Sepolia Testnet |
| Smart Contract | [0xa000DA2d2D332b8F33fcEd58AFfA851F05B35a7d](https://sepolia.etherscan.io/address/0xa000DA2d2D332b8F33fcEd58AFfA851F05B35a7d) |
| Source code | [SkillTrustCertificate.sol](SkillTrustCertificate.sol) |
| Frontend | HTML + JavaScript + ethers.js v6 + Metamask |

## วิธีใช้งาน

1. เปิดเว็บ แล้วกด **Connect Metamask** (เลือก Sepolia)
2. Admin: ไปที่แท็บ **หลักสูตร** เพื่อสร้างหลักสูตร
3. Issuer: ไปที่แท็บ **ออกใบรับรอง** กรอกชื่อและ Wallet ผู้รับ แล้วพิมพ์/บันทึกใบรับรองเป็น PDF
4. ผู้ว่าจ้าง: ไปที่แท็บ **ตรวจสอบใบรับรอง** ใส่รหัสหรือสแกน QR และกรอกชื่อ + Verification Code เพื่อตรวจว่าเอกสารถูกแก้ไขหรือไม่
