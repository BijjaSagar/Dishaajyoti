-- DishaAjyoti Database Schema
-- MySQL 8.0+

-- Drop existing tables if they exist
DROP TABLE IF EXISTS `ai_responses`;
DROP TABLE IF EXISTS `report_details`;
DROP TABLE IF EXISTS `reports`;
DROP TABLE IF EXISTS `payments`;
DROP TABLE IF EXISTS `user_queries`;
DROP TABLE IF EXISTS `pdf_documents`;
DROP TABLE IF EXISTS `service_features`;
DROP TABLE IF EXISTS `services`;
DROP TABLE IF EXISTS `user_profiles`;
DROP TABLE IF EXISTS `users`;
DROP TABLE IF EXISTS `categories`;

-- ============================================
-- Categories Table
-- ============================================
CREATE TABLE `categories` (
  `id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  `name` VARCHAR(100) NOT NULL UNIQUE,
  `slug` VARCHAR(100) NOT NULL UNIQUE,
  `description` TEXT,
  `icon` VARCHAR(255),
  `display_order` INT DEFAULT 0,
  `is_active` BOOLEAN DEFAULT TRUE,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX `idx_slug` (`slug`),
  INDEX `idx_active` (`is_active`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- Users Table
-- ============================================
CREATE TABLE `users` (
  `id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  `email` VARCHAR(255) NOT NULL UNIQUE,
  `phone` VARCHAR(20) UNIQUE,
  `password_hash` VARCHAR(255) NOT NULL,
  `full_name` VARCHAR(200) NOT NULL,
  `email_verified` BOOLEAN DEFAULT FALSE,
  `phone_verified` BOOLEAN DEFAULT FALSE,
  `is_active` BOOLEAN DEFAULT TRUE,
  `last_login_at` TIMESTAMP NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX `idx_email` (`email`),
  INDEX `idx_phone` (`phone`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- User Profiles Table
-- ============================================
CREATE TABLE `user_profiles` (
  `id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  `user_id` INT UNSIGNED NOT NULL UNIQUE,
  `date_of_birth` DATE,
  `time_of_birth` TIME,
  `place_of_birth` VARCHAR(255),
  `latitude` DECIMAL(10, 8),
  `longitude` DECIMAL(11, 8),
  `gender` ENUM('male', 'female', 'other'),
  `marital_status` ENUM('single', 'married', 'divorced', 'widowed'),
  `occupation` VARCHAR(255),
  `profile_picture` VARCHAR(255),
  `language_preference` VARCHAR(10) DEFAULT 'en',
  `timezone` VARCHAR(50) DEFAULT 'Asia/Kolkata',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE,
  INDEX `idx_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- Services Table (Dynamic)
-- ============================================
CREATE TABLE `services` (
  `id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  `category_id` INT UNSIGNED NOT NULL,
  `name` VARCHAR(255) NOT NULL,
  `slug` VARCHAR(255) NOT NULL UNIQUE,
  `description` TEXT NOT NULL,
  `detailed_description` TEXT,
  `icon` VARCHAR(255),
  `image_url` VARCHAR(255),
  `price` DECIMAL(10, 2) NOT NULL,
  `currency` VARCHAR(3) DEFAULT 'INR',
  `estimated_time` VARCHAR(50),
  `ai_agent_type` VARCHAR(100) NOT NULL COMMENT 'jyotisha, vastu, numerology, etc.',
  `is_active` BOOLEAN DEFAULT TRUE,
  `is_featured` BOOLEAN DEFAULT FALSE,
  `display_order` INT DEFAULT 0,
  `metadata` JSON COMMENT 'Additional service-specific data',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (`category_id`) REFERENCES `categories`(`id`) ON DELETE CASCADE,
  INDEX `idx_slug` (`slug`),
  INDEX `idx_category` (`category_id`),
  INDEX `idx_active` (`is_active`),
  INDEX `idx_featured` (`is_featured`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- Service Features Table
-- ============================================
CREATE TABLE `service_features` (
  `id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  `service_id` INT UNSIGNED NOT NULL,
  `feature_text` VARCHAR(500) NOT NULL,
  `display_order` INT DEFAULT 0,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (`service_id`) REFERENCES `services`(`id`) ON DELETE CASCADE,
  INDEX `idx_service_id` (`service_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- PDF Documents Table
-- ============================================
CREATE TABLE `pdf_documents` (
  `id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  `service_type` VARCHAR(100) NOT NULL COMMENT 'jyotisha, vastu, numerology, etc.',
  `filename` VARCHAR(255) NOT NULL,
  `original_name` VARCHAR(255) NOT NULL,
  `file_path` VARCHAR(500) NOT NULL,
  `file_size` BIGINT UNSIGNED,
  `page_count` INT,
  `is_processed` BOOLEAN DEFAULT FALSE,
  `is_active` BOOLEAN DEFAULT TRUE,
  `pinecone_namespace` VARCHAR(255) COMMENT 'Namespace in Pinecone',
  `embedding_count` INT DEFAULT 0,
  `processed_at` TIMESTAMP NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX `idx_service_type` (`service_type`),
  INDEX `idx_processed` (`is_processed`),
  INDEX `idx_active` (`is_active`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- User Queries Table (For AI Interaction)
-- ============================================
CREATE TABLE `user_queries` (
  `id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  `user_id` INT UNSIGNED NOT NULL,
  `service_id` INT UNSIGNED NOT NULL,
  `query_text` TEXT NOT NULL,
  `query_metadata` JSON COMMENT 'Additional query parameters',
  `session_id` VARCHAR(100),
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE,
  FOREIGN KEY (`service_id`) REFERENCES `services`(`id`) ON DELETE CASCADE,
  INDEX `idx_user_id` (`user_id`),
  INDEX `idx_service_id` (`service_id`),
  INDEX `idx_session` (`session_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- Payments Table
-- ============================================
CREATE TABLE `payments` (
  `id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  `user_id` INT UNSIGNED NOT NULL,
  `service_id` INT UNSIGNED NOT NULL,
  `amount` DECIMAL(10, 2) NOT NULL,
  `currency` VARCHAR(3) DEFAULT 'INR',
  `payment_method` VARCHAR(50),
  `payment_gateway` VARCHAR(50) COMMENT 'razorpay, stripe, etc.',
  `transaction_id` VARCHAR(255) UNIQUE,
  `gateway_order_id` VARCHAR(255),
  `gateway_payment_id` VARCHAR(255),
  `status` ENUM('pending', 'processing', 'completed', 'failed', 'refunded') DEFAULT 'pending',
  `payment_metadata` JSON,
  `paid_at` TIMESTAMP NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE,
  FOREIGN KEY (`service_id`) REFERENCES `services`(`id`) ON DELETE CASCADE,
  INDEX `idx_user_id` (`user_id`),
  INDEX `idx_transaction` (`transaction_id`),
  INDEX `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- Reports Table
-- ============================================
CREATE TABLE `reports` (
  `id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  `user_id` INT UNSIGNED NOT NULL,
  `service_id` INT UNSIGNED NOT NULL,
  `payment_id` INT UNSIGNED,
  `report_title` VARCHAR(255) NOT NULL,
  `report_type` VARCHAR(100) NOT NULL,
  `status` ENUM('pending', 'processing', 'completed', 'failed') DEFAULT 'pending',
  `file_url` VARCHAR(500),
  `file_path` VARCHAR(500),
  `file_size` BIGINT UNSIGNED,
  `generation_metadata` JSON COMMENT 'Input data for report generation',
  `error_message` TEXT,
  `generated_at` TIMESTAMP NULL,
  `expires_at` TIMESTAMP NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE,
  FOREIGN KEY (`service_id`) REFERENCES `services`(`id`) ON DELETE CASCADE,
  FOREIGN KEY (`payment_id`) REFERENCES `payments`(`id`) ON DELETE SET NULL,
  INDEX `idx_user_id` (`user_id`),
  INDEX `idx_service_id` (`service_id`),
  INDEX `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- Report Details Table
-- ============================================
CREATE TABLE `report_details` (
  `id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  `report_id` INT UNSIGNED NOT NULL,
  `section_name` VARCHAR(255) NOT NULL,
  `section_content` LONGTEXT NOT NULL,
  `section_order` INT DEFAULT 0,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (`report_id`) REFERENCES `reports`(`id`) ON DELETE CASCADE,
  INDEX `idx_report_id` (`report_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- AI Responses Table (Cache & Analytics)
-- ============================================
CREATE TABLE `ai_responses` (
  `id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  `query_id` INT UNSIGNED NOT NULL,
  `agent_type` VARCHAR(100) NOT NULL,
  `response_text` LONGTEXT NOT NULL,
  `source_documents` JSON COMMENT 'References to PDF sources used',
  `confidence_score` DECIMAL(3, 2),
  `processing_time_ms` INT,
  `tokens_used` INT,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (`query_id`) REFERENCES `user_queries`(`id`) ON DELETE CASCADE,
  INDEX `idx_query_id` (`query_id`),
  INDEX `idx_agent_type` (`agent_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- Insert Default Categories
-- ============================================
INSERT INTO `categories` (`name`, `slug`, `description`, `icon`, `display_order`) VALUES
('Vedic Astrology', 'vedic-astrology', 'Traditional Jyotish services including Kundali, predictions, and remedies', '🔮', 1),
('Vastu Shastra', 'vastu-shastra', 'Architectural harmony and space design consulting', '🏛️', 2),
('Numerology', 'numerology', 'Numbers and their mystical significance in your life', '🔢', 3),
('Palmistry', 'palmistry', 'Hand reading and palm analysis', '✋', 4),
('Gemology', 'gemology', 'Gemstone recommendations and remedies', '💎', 5),
('Muhurta', 'muhurta', 'Auspicious timing for important events', '⏰', 6),
('Prashna', 'prashna', 'Horary astrology - answers to specific questions', '❓', 7),
('Remedies', 'remedies', 'Astrological remedies and solutions', '🙏', 8);

-- ============================================
-- Insert Sample Services
-- ============================================
INSERT INTO `services` (`category_id`, `name`, `slug`, `description`, `detailed_description`, `price`, `estimated_time`, `ai_agent_type`, `is_featured`) VALUES
(1, 'Complete Kundali Analysis', 'kundali-analysis', 'Comprehensive birth chart analysis with predictions', 'Get detailed insights into your life path, career, relationships, and health based on Vedic astrology principles.', 499.00, '2-3 hours', 'jyotisha', TRUE),
(1, 'Marriage Compatibility', 'marriage-compatibility', 'Detailed compatibility analysis for marriage', 'Gun Milan and comprehensive compatibility report for prospective matches.', 699.00, '1-2 hours', 'jyotisha', TRUE),
(2, 'Residential Vastu Consultation', 'residential-vastu', 'Complete Vastu analysis for your home', 'Detailed Vastu consultation with remedies and recommendations for your residence.', 999.00, '3-4 hours', 'vastu', TRUE),
(3, 'Numerology Life Path Reading', 'numerology-reading', 'Discover your life path through numbers', 'Complete numerological analysis including life path, destiny, and soul numbers.', 299.00, '1-2 hours', 'numerology', FALSE),
(4, 'Complete Palmistry Reading', 'palmistry-reading', 'Detailed palm analysis and predictions', 'Comprehensive palm reading covering all aspects of life.', 399.00, '1-2 hours', 'palmistry', FALSE);

-- ============================================
-- Insert Service Features
-- ============================================
INSERT INTO `service_features` (`service_id`, `feature_text`, `display_order`) VALUES
(1, 'Complete planetary positions and house analysis', 1),
(1, 'Dasha predictions for next 10 years', 2),
(1, 'Career and financial guidance', 3),
(1, 'Health and wellness insights', 4),
(1, 'Relationship and marriage timing', 5),
(1, 'Remedial measures and gemstone recommendations', 6),
(2, 'Ashtakoot Guna Milan (8-point compatibility)', 1),
(2, 'Manglik Dosha analysis', 2),
(2, 'Personality compatibility assessment', 3),
(2, 'Relationship strengths and challenges', 4),
(2, 'Auspicious marriage dates', 5);
