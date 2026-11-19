// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title SkillTrust Academy - Blockchain Digital Certificate Verification System
/// @notice เก็บเฉพาะ "หลักฐาน" ของใบรับรอง (hash) บน blockchain
///         ข้อมูลส่วนบุคคล (ชื่อ-สกุลผู้รับ) ไม่ถูกบันทึกบน chain โดยตรง
/// @dev Deployed on Sepolia: 0xa000DA2d2D332b8F33fcEd58AFfA851F05B35a7d
contract SkillTrustCertificate {
    // ---------- Roles ----------
    address public owner;                       // ผู้ดูแลระบบหลัก
    mapping(address => bool) public isIssuer;   // ผู้ที่ได้รับสิทธิ์ออก/เพิกถอนใบรับรอง

    // ---------- Data ----------
    struct Course {
        string code;
        string name;
        string details;
        uint256 createdAt;
        bool exists;
    }

    struct Certificate {
        string certId;        // รหัสใบรับรอง (ไม่ซ้ำ)
        string courseCode;    // รหัสหลักสูตร
        address recipient;    // wallet ของผู้รับ
        bytes32 certHash;     // hash ของข้อมูลใบรับรอง (ใช้ยืนยันว่าเอกสารไม่ถูกแก้ไข)
        uint256 issuedAt;     // วันที่ออก (block timestamp)
        address issuedBy;     // ผู้ออก
        bool revoked;         // สถานะเพิกถอน
        uint256 revokedAt;
        string revokeReason;
        bool exists;
    }

    mapping(string => Course) private courses;
    string[] private courseCodes;

    mapping(string => Certificate) private certificates;
    string[] private certIds;
    mapping(address => string[]) private certsOfRecipient;
    mapping(bytes32 => string) public certIdByHash;

    // ---------- Events ----------
    event IssuerUpdated(address indexed account, bool allowed);
    event CourseCreated(string code, string name);
    event CertificateIssued(string certId, string courseCode, address indexed recipient, bytes32 certHash, address indexed issuedBy);
    event CertificateRevoked(string certId, string reason, address indexed revokedBy);

    // ---------- Modifiers ----------
    modifier onlyOwner() {
        require(msg.sender == owner, "Only admin");
        _;
    }

    modifier onlyIssuer() {
        require(msg.sender == owner || isIssuer[msg.sender], "Not authorized issuer");
        _;
    }

    constructor() {
        owner = msg.sender;
        isIssuer[msg.sender] = true;
        emit IssuerUpdated(msg.sender, true);
    }

    // ---------- Admin ----------
    function setIssuer(address account, bool allowed) external onlyOwner {
        require(account != address(0), "Invalid address");
        isIssuer[account] = allowed;
        emit IssuerUpdated(account, allowed);
    }

    // 1. ลงทะเบียนหลักสูตร
    function createCourse(string calldata code, string calldata name, string calldata details) external onlyOwner {
        require(bytes(code).length > 0 && bytes(name).length > 0, "Code and name required");
        require(!courses[code].exists, "Course code already exists");
        courses[code] = Course(code, name, details, block.timestamp, true);
        courseCodes.push(code);
        emit CourseCreated(code, name);
    }

    // 2 + 3. ออกใบรับรองและบันทึก hash บน blockchain
    function issueCertificate(
        string calldata certId,
        string calldata courseCode,
        address recipient,
        bytes32 certHash
    ) external onlyIssuer {
        require(bytes(certId).length > 0, "Certificate ID required");
        require(!certificates[certId].exists, "Certificate ID already exists");
        require(courses[courseCode].exists, "Course not found");
        require(recipient != address(0), "Invalid recipient");
        require(certHash != bytes32(0), "Hash required");
        require(bytes(certIdByHash[certHash]).length == 0, "Hash already used");

        certificates[certId] = Certificate({
            certId: certId,
            courseCode: courseCode,
            recipient: recipient,
            certHash: certHash,
            issuedAt: block.timestamp,
            issuedBy: msg.sender,
            revoked: false,
            revokedAt: 0,
            revokeReason: "",
            exists: true
        });
        certIds.push(certId);
        certsOfRecipient[recipient].push(certId);
        certIdByHash[certHash] = certId;

        emit CertificateIssued(certId, courseCode, recipient, certHash, msg.sender);
    }

    // 5. เพิกถอนใบรับรอง (ยังเก็บประวัติไว้)
    function revokeCertificate(string calldata certId, string calldata reason) external onlyIssuer {
        Certificate storage c = certificates[certId];
        require(c.exists, "Certificate not found");
        require(!c.revoked, "Already revoked");
        c.revoked = true;
        c.revokedAt = block.timestamp;
        c.revokeReason = reason;
        emit CertificateRevoked(certId, reason, msg.sender);
    }

    // ---------- Views ----------
    // 4. ตรวจสอบความถูกต้อง: valid = มีอยู่จริงและยังไม่ถูกเพิกถอน
    function verifyCertificate(string calldata certId) external view returns (bool exists, bool valid, bytes32 certHash) {
        Certificate storage c = certificates[certId];
        return (c.exists, c.exists && !c.revoked, c.certHash);
    }

    // ตรวจว่า hash ของเอกสารตรงกับที่บันทึกไว้หรือไม่
    function verifyHash(string calldata certId, bytes32 documentHash) external view returns (bool) {
        Certificate storage c = certificates[certId];
        return c.exists && c.certHash == documentHash;
    }

    function getCertificate(string calldata certId) external view returns (Certificate memory) {
        require(certificates[certId].exists, "Certificate not found");
        return certificates[certId];
    }

    function getCourse(string calldata code) external view returns (Course memory) {
        require(courses[code].exists, "Course not found");
        return courses[code];
    }

    function getCourseCodes() external view returns (string[] memory) {
        return courseCodes;
    }

    // 6. รายการใบรับรองที่ผูกกับ wallet
    function getCertificatesOf(address recipient) external view returns (string[] memory) {
        return certsOfRecipient[recipient];
    }

    function totalCertificates() external view returns (uint256) {
        return certIds.length;
    }

    function certificateIdAt(uint256 index) external view returns (string memory) {
        return certIds[index];
    }
}
