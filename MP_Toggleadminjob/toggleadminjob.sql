-- ============================================================
--  toggleadminjob — SQL Installation File
--  Framework : QBox (qbx_core)
--  Run this manually in your database manager (HeidiSQL,
--  phpMyAdmin, TablePlus, etc.) if you prefer not to rely
--  on the auto-create that happens at resource start.
-- ============================================================

CREATE TABLE IF NOT EXISTS `toggleadminjob_saved` (
    `citizenid`   VARCHAR(50)  NOT NULL,
    `saved_job`   VARCHAR(50)  NOT NULL DEFAULT 'unemployed',
    `saved_grade` INT          NOT NULL DEFAULT 0,
    `saved_label` VARCHAR(100) NOT NULL DEFAULT 'Unemployed',
    `toggled_at`  TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`citizenid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
--  Column Reference
--  citizenid  — QBox player citizenid (e.g. 'ABC12345')
--  saved_job  — Job name at time of toggle (e.g. 'mechanic')
--  saved_grade— Grade/level of that job   (e.g. 2)
--  saved_label— Display label             (e.g. 'Mechanic')
--  toggled_at — Last toggle timestamp (auto-updated)
-- ============================================================
