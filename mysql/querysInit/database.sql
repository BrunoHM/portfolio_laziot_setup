-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema laziot
-- -----------------------------------------------------
DROP SCHEMA IF EXISTS `laziot` ;

-- -----------------------------------------------------
-- Schema laziot
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `laziot` DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci;
USE `laziot` ;

-- -----------------------------------------------------
-- Table `laziot`.`device`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `laziot`.`device` ;

CREATE TABLE IF NOT EXISTS `laziot`.`device` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `description` VARCHAR(200) NULL,
  `place` VARCHAR(45) NULL,
  `uniqueDeviceCode` VARCHAR(50) NULL,
  `qtdPinsIO` SMALLINT(3) NULL,
  `type` VARCHAR(10) NULL COMMENT 'Tipos padrões: emissor e receptor',
  `active` TINYINT(1) NULL,
  PRIMARY KEY (`id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `laziot`.`action`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `laziot`.`action` ;

CREATE TABLE IF NOT EXISTS `laziot`.`action` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `description` VARCHAR(45) NULL,
  `triggerIOPin` SMALLINT(3) NULL,
  `doubleAction` TINYINT(1) NULL,
  `delay` TIME NULL,
  `active` TINYINT(1) NULL,
  `fkDeviceId` INT NOT NULL,
  PRIMARY KEY (`id`),
  INDEX `fk_Acao_Dispositivo1_idx` (`fkDeviceId` ASC) VISIBLE,
  CONSTRAINT `fk_Acao_Dispositivo1`
    FOREIGN KEY (`fkDeviceId`)
    REFERENCES `laziot`.`device` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `laziot`.`user`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `laziot`.`user` ;

CREATE TABLE IF NOT EXISTS `laziot`.`user` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(45) NULL,
  `lastname` VARCHAR(45) NULL,
  `email` VARCHAR(45) NULL,
  `hashPassword` VARCHAR(45) NULL,
  `hashUniqueCode` VARCHAR(50) NOT NULL,
  `active` TINYINT(1) NULL,
  PRIMARY KEY (`id`),
  UNIQUE INDEX `login_UNIQUE` (`email` ASC) VISIBLE,
  UNIQUE INDEX `hashCodigoUnico_UNIQUE` (`hashUniqueCode` ASC) VISIBLE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `laziot`.`event`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `laziot`.`event` ;

CREATE TABLE IF NOT EXISTS `laziot`.`event` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `date` DATE NULL,
  `time` TIME NULL,
  `manual` TINYINT(1) NULL COMMENT 'Indica se o evento foi gerado automaticamente ou não.',
  `executed` TINYINT(1) NULL,
  `fkIdAction` INT NOT NULL,
  `fkIdUser` INT NOT NULL,
  PRIMARY KEY (`id`),
  INDEX `fk_Evento_Acao1_idx` (`fkIdAction` ASC) VISIBLE,
  INDEX `fk_evento_usuario1_idx` (`fkIdUser` ASC) VISIBLE,
  CONSTRAINT `fk_Evento_Acao1`
    FOREIGN KEY (`fkIdAction`)
    REFERENCES `laziot`.`action` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_evento_usuario1`
    FOREIGN KEY (`fkIdUser`)
    REFERENCES `laziot`.`user` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `laziot`.`equivalentDevice`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `laziot`.`equivalentDevice` ;

CREATE TABLE IF NOT EXISTS `laziot`.`equivalentDevice` (
  `idDispositivoMae` INT NOT NULL,
  `idDispositivoFilho` INT NOT NULL,
  PRIMARY KEY (`idDispositivoMae`, `idDispositivoFilho`),
  INDEX `fk_Dispositivo_has_Dispositivo_Dispositivo2_idx` (`idDispositivoFilho` ASC) VISIBLE,
  INDEX `fk_Dispositivo_has_Dispositivo_Dispositivo1_idx` (`idDispositivoMae` ASC) VISIBLE,
  CONSTRAINT `fk_Dispositivo_has_Dispositivo_Dispositivo1`
    FOREIGN KEY (`idDispositivoMae`)
    REFERENCES `laziot`.`device` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Dispositivo_has_Dispositivo_Dispositivo2`
    FOREIGN KEY (`idDispositivoFilho`)
    REFERENCES `laziot`.`device` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `laziot`.`userDevices`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `laziot`.`userDevices` ;

CREATE TABLE IF NOT EXISTS `laziot`.`userDevices` (
  `user_id` INT NOT NULL,
  `device_id` INT NOT NULL,
  PRIMARY KEY (`user_id`, `device_id`),
  INDEX `fk_usuario_has_dispositivo_dispositivo1_idx` (`device_id` ASC) VISIBLE,
  INDEX `fk_usuario_has_dispositivo_usuario1_idx` (`user_id` ASC) VISIBLE,
  CONSTRAINT `fk_usuario_has_dispositivo_usuario1`
    FOREIGN KEY (`user_id`)
    REFERENCES `laziot`.`user` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_usuario_has_dispositivo_dispositivo1`
    FOREIGN KEY (`device_id`)
    REFERENCES `laziot`.`device` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `laziot`.`parameters`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `laziot`.`parameters` ;

CREATE TABLE IF NOT EXISTS `laziot`.`parameters` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `description` VARCHAR(120) NULL,
  `value` VARCHAR(120) NULL,
  `active` TINYINT(1) NULL,
  `user_id` INT NOT NULL,
  PRIMARY KEY (`id`),
  INDEX `fk_parameters_user1_idx` (`user_id` ASC) VISIBLE,
  CONSTRAINT `fk_parameters_user1`
    FOREIGN KEY (`user_id`)
    REFERENCES `laziot`.`user` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `laziot`.`codeDevice`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `laziot`.`codeDevice` ;

CREATE TABLE IF NOT EXISTS `laziot`.`codeDevice` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `textCode` MEDIUMTEXT NULL,
  `device` VARCHAR(45) NULL,
  `typeDevice` VARCHAR(10) NULL,
  `linkedTo` VARCHAR(45) NULL,
  `active` TINYINT(1) NULL,
  PRIMARY KEY (`id`))
ENGINE = InnoDB;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;

USE `laziot` ;

INSERT INTO `user` (`name`, `lastname`, `email`, `hashPassword`, `hashUniqueCode`, `active`) VALUES
("Usuário", "Automático", null, null, "hash1", 1)
;

