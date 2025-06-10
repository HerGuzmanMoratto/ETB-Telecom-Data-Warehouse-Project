-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- =====================================================
-- Schema TelecomTask Database Practical implementation
-- =====================================================
-- PHASE 2.1.	Schema Implementation with DDL
-- This phase focuses in TABLE CREATION:
--  Defining foreign keys and relationships between tables
-- Constraints such as NOT NULL, CHECK, and ENUM for data validation.
-- Timestamps with createdAt and updatedAt columns based on CURRENT_TIMESTAMP.
-- =====================================================
-- Schema TelecomTask: SCHEMA CREATION 
-- =====================================================
-- starts dropping schema if exists to avoid errors.
DROP SCHEMA IF EXISTS TelecomTask;
CREATE SCHEMA IF NOT EXISTS TelecomTask DEFAULT CHARACTER SET UTF8MB4 ;
USE TelecomTask ;
-- =====================================================
-- TABLES DROPPING BEFORE CREATION FOR BEST PRACTICES:
-- =====================================================
DROP TABLE IF EXISTS Country; 			-- Done
DROP TABLE IF EXISTS Branch;  			-- Done
DROP TABLE IF EXISTS Customer; 			-- Done
DROP TABLE IF EXISTS ServicePlan; 		-- Done
DROP TABLE IF EXISTS Time;				-- Done
DROP TABLE IF EXISTS Employee;			-- Done
DROP TABLE IF EXISTS UsageRecord;		
DROP TABLE IF EXISTS BillingRecord;		-- Done
DROP TABLE IF EXISTS SupportTicket;		-- Done
DROP TABLE IF EXISTS ProcessLog ;
DROP TABLE IF EXISTS RevenueTarget;

-- =====================================================}
-- Table creation phase.
-- =====================================================
-- 				Table 1. Country
-- =====================================================
CREATE TABLE IF NOT EXISTS Country (
    CountryID INT NOT NULL,
    CountryName VARCHAR(100) NOT NULL,
    PRIMARY KEY (CountryID)
)  ENGINE=INNODB;
-- =====================================================
-- 				Table 2. Branch
-- =====================================================
CREATE TABLE IF NOT EXISTS Branch (
    BranchID INT NOT NULL,
    BranchName VARCHAR(100) NULL,
    CountryID INT NULL,
    CreatedAt DATETIME DEFAULT CURRENT_TIMESTAMP,
    UpdatedAt DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (BranchID),
    CONSTRAINT fk_branch_country FOREIGN KEY (CountryID)
        REFERENCES Country (CountryID)
        ON DELETE CASCADE ON UPDATE NO ACTION
)  ENGINE=INNODB;
-- =====================================================
-- 				Table 3. Customer
-- =====================================================
CREATE TABLE IF NOT EXISTS Customer (
    CustomerID INT NOT NULL AUTO_INCREMENT,
    Name VARCHAR(100) NOT NULL,
    Last_name VARCHAR(100) NOT NULL,
    Email VARCHAR(100) NOT NULL CHECK (Email LIKE '%@%.%'),
    Phone_number VARCHAR(20) NOT NULL,
    CountryID INT NOT NULL,
    BranchID INT NOT NULL,
    PRIMARY KEY (CustomerID),
    CONSTRAINT fk_customer_country FOREIGN KEY (CountryID)
        REFERENCES Country (CountryID)
        ON DELETE RESTRICT ON UPDATE NO ACTION,
    CONSTRAINT fk_customer_branch FOREIGN KEY (BranchID)
        REFERENCES Branch (BranchID)
        ON DELETE CASCADE ON UPDATE NO ACTION
)  ENGINE=INNODB;
-- =====================================================
-- 				Table 4. ServicePlan
-- =====================================================
CREATE TABLE IF NOT EXISTS ServicePlan (
  PlanID INT NOT NULL,
  PlanName VARCHAR(100),
  MonthlyFee DECIMAL(12,2) NOT NULL DEFAULT 0,
  DataLimitGB INT NULL,
  SMSLimit INT NULL,
  VoiceMinutes INT NULL,
  AddsOn JSON NULL,
  createdAt DATETIME DEFAULT CURRENT_TIMESTAMP,
  updatedAt DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (PlanID))
ENGINE = InnoDB;
-- =====================================================
-- 				Table 5. Time
-- =====================================================
CREATE TABLE IF NOT EXISTS Time (
    TimeID INT NOT NULL,
    Date DATE NOT NULL,
    Month VARCHAR(45),
    Year INT NULL,
    Quarter VARCHAR(45) NULL,
    PRIMARY KEY (TimeID)
)  ENGINE=INNODB;
-- =====================================================
-- 				Table 6. Employees
-- =====================================================
CREATE TABLE IF NOT EXISTS Employee (
    EmployeeID INT NOT NULL,
    FullName VARCHAR(100),
    Role VARCHAR(45),
    BranchID INT NOT NULL,
    Hired_Date DATE,
    Wave INT,
    createdAt DATETIME DEFAULT CURRENT_TIMESTAMP,
    updatedAt DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (EmployeeID),
    CONSTRAINT fk_employee_branch FOREIGN KEY (BranchID)
        REFERENCES Branch (BranchID)
        ON DELETE CASCADE ON UPDATE NO ACTION
)  ENGINE=INNODB;
-- =====================================================
-- 				Table 7. UsageRecord
-- =====================================================
CREATE TABLE IF NOT EXISTS UsageRecord (
    UsageID INT NOT NULL,
    CustomerID INT NOT NULL,
    PlanID INT,
    TimeID INT,
    DataUsedGB DECIMAL(10 , 2 ),
    SMSUsed INT,
    VoiceMinutesUsed INT,
    createdAt DATETIME DEFAULT CURRENT_TIMESTAMP,
    updatedAt DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (UsageID),
    CONSTRAINT fk_usage_customer FOREIGN KEY (CustomerID)
        REFERENCES Customer (CustomerID)
        ON DELETE CASCADE ON UPDATE NO ACTION,
    CONSTRAINT fk_usage_plan FOREIGN KEY (PlanID)
        REFERENCES ServicePlan (PlanID)
        ON DELETE SET NULL ON UPDATE NO ACTION,
    CONSTRAINT fk_usage_time FOREIGN KEY (TimeID)
        REFERENCES Time (TimeID)
        ON DELETE RESTRICT ON UPDATE NO ACTION
)  ENGINE=INNODB;
-- =====================================================
-- 				Table 8. BillingRecords
-- =====================================================
CREATE TABLE IF NOT EXISTS BillingRecord (
    BillID INT NOT NULL,
    CustomerID INT,
    PlanID INT,
    TimeID INT,
    AmountDue DECIMAL(12 , 2 ) DEFAULT 0,
    AmountPaid DECIMAL(12 , 2 ) DEFAULT 0,
    PaymentStatus ENUM('Paid', 'Pending', 'Late'),
    createdAt DATETIME DEFAULT CURRENT_TIMESTAMP,
    updatedAt DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (BillID),
    CONSTRAINT fk_billing_customer FOREIGN KEY (CustomerID)
        REFERENCES Customer (CustomerID)
        ON DELETE CASCADE ON UPDATE NO ACTION,
    CONSTRAINT fk_billing_plan FOREIGN KEY (PlanID)
        REFERENCES ServicePlan (PlanID)
        ON DELETE SET NULL ON UPDATE NO ACTION,
    CONSTRAINT fk_billing_time FOREIGN KEY (TimeID)
        REFERENCES Time (TimeID)
        ON DELETE RESTRICT ON UPDATE NO ACTION
)  ENGINE=INNODB;
-- =====================================================
-- 				Table 9. SupportTicket
-- =====================================================
CREATE TABLE IF NOT EXISTS SupportTicket (
  TicketID INT NOT NULL,
  CustomerID INT,
  BranchID INT,
  EmployeeID INT,
  TimeID INT,
  IssueType VARCHAR(100),
  Channel ENUM('Phone', 'App', 'Email', 'In-Person') NOT NULL,
  ResolutionTime INT,
  CustomerSatisfaction TINYINT(1),
  InteractionHistory JSON NULL,
  createdAt DATETIME DEFAULT CURRENT_TIMESTAMP,
  updatedAt DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (TicketID),
  CONSTRAINT fk_ticket_customer
    FOREIGN KEY (CustomerID)
    REFERENCES Customer (CustomerID)
    ON DELETE CASCADE
    ON UPDATE NO ACTION,
  CONSTRAINT fk_ticket_branch
    FOREIGN KEY (BranchID)
    REFERENCES Branch (BranchID)
    ON DELETE CASCADE
    ON UPDATE NO ACTION,
  CONSTRAINT fk_ticket_employee
    FOREIGN KEY (EmployeeID)
    REFERENCES Employee (EmployeeID)
    ON DELETE SET NULL
    ON UPDATE NO ACTION,
  CONSTRAINT fk_ticket_time
    FOREIGN KEY (TimeID)
    REFERENCES Time (TimeID)
    ON DELETE RESTRICT
    ON UPDATE NO ACTION)
ENGINE = InnoDB;
-- =====================================================
-- 				Table 10. ProcessLog
-- =====================================================
CREATE TABLE IF NOT EXISTS ProcessLog (
    LogID INT NOT NULL,
    ProcessType ENUM('Billing', 'Activation', 'Support', 'PlanChange') NOT NULL,
    CustomerID INT,
    BranchID INT,
    StartTime DATETIME,
    EndTime DATETIME,
    DurationSec INT,
    Status ENUM('Completed', 'Failed', 'In-Progress') NOT NULL,
    createdAt DATETIME DEFAULT CURRENT_TIMESTAMP,
    updatedAt DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (LogID),
    CONSTRAINT fk_log_cusomer FOREIGN KEY (CustomerID)
        REFERENCES Customer (CustomerID)
        ON DELETE CASCADE ON UPDATE NO ACTION,
    CONSTRAINT fk_log_branch FOREIGN KEY (BranchID)
        REFERENCES Branch (BranchID)
        ON DELETE CASCADE ON UPDATE NO ACTION
)  ENGINE=INNODB;
-- =====================================================
-- 				Table 11. RevenueTarget
-- =====================================================
CREATE TABLE IF NOT EXISTS RevenueTarget (
    TargetID INT NOT NULL,
    BranchID INT,
    PlanID INT,
    TimeID INT,
    MonthlyTarget DECIMAL(15 , 2 ),
    createdAt DATETIME DEFAULT CURRENT_TIMESTAMP,
    updatedAt DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (TargetID),
    CONSTRAINT fk_target_branch FOREIGN KEY (BranchID)
        REFERENCES Branch (BranchID)
        ON DELETE RESTRICT ON UPDATE NO ACTION,
    CONSTRAINT fk_target_plan FOREIGN KEY (PlanID)
        REFERENCES ServicePlan (PlanID)
        ON DELETE SET NULL ON UPDATE NO ACTION,
    CONSTRAINT fk_target_time FOREIGN KEY (TimeID)
        REFERENCES Time (TimeID)
        ON DELETE RESTRICT ON UPDATE NO ACTION
)  ENGINE=INNODB;
-- =====================================================
SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;