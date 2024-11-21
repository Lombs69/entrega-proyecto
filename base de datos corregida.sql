CREATE DATABASE `VENTAS`;

USE `VENTAS`;

-- Tabla USUARIO
CREATE TABLE `USUARIO`(
    `ID_Usuario` INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `Nombre` VARCHAR(255) NOT NULL,
    `Rol` INT UNSIGNED NOT NULL,
    `Password` VARCHAR(255) NOT NULL
);
ALTER TABLE
    `USUARIO` ADD INDEX `usuario_rol_index`(`Rol`);

-- Tabla ROLES
CREATE TABLE `ROLES`(
    `ID` INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `Nombre` VARCHAR(255) NOT NULL
);

-- Tabla CLIENTE
CREATE TABLE `CLIENTE`(
    `ID_Cliente` INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `Nombre` VARCHAR(255) NOT NULL,
    `Dirección` VARCHAR(255) NOT NULL,
    `Correo` VARCHAR(255) NOT NULL,
    `Password` VARCHAR(255) NOT NULL
);

-- Tabla PRODUCTO
CREATE TABLE `PRODUCTO`(
    `ID_Producto` INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `Descripción` TEXT NOT NULL,
    `Precio` DECIMAL(10, 2) NOT NULL,
    `Nombre` VARCHAR(255) NOT NULL,
    `Stock` INT NOT NULL,
    `Referencia` VARCHAR(255) NOT NULL,
    `Img` VARCHAR(255) NOT NULL
);

-- Tabla PROVEDOR
CREATE TABLE `PROVEDOR`(
    `ID_Provedor` INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `Nombre` VARCHAR(255) NOT NULL,
    `Dirección` VARCHAR(255) NOT NULL,
    `Teléfono` VARCHAR(20) NOT NULL,
    `Correo` VARCHAR(255) NOT NULL,
    `ID_TransfeFK` INT UNSIGNED NOT NULL,
    `Estado` VARCHAR(50) NOT NULL
);
ALTER TABLE
    `PROVEDOR` ADD INDEX `provedor_id_transfefk_index`(`ID_TransfeFK`);

-- Tabla TIPO_PROVEDOR
CREATE TABLE `TIPO_PROVEDOR`(
    `ID` INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `Nombre` VARCHAR(255) NOT NULL
);

-- Tabla OPINION_CLIENTE
CREATE TABLE `OPINION_CLIENTE`(
    `ID` INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `ID_Cliente` INT UNSIGNED NOT NULL,
    `ID_Transaccion` INT UNSIGNED NOT NULL,
    `Fecha` DATE NOT NULL,
    `Descripción` VARCHAR(255) NOT NULL
);
ALTER TABLE
    `OPINION_CLIENTE` ADD INDEX `opinion_cliente_id_cliente_index`(`ID_Cliente`);
ALTER TABLE
    `OPINION_CLIENTE` ADD INDEX `opinion_cliente_id_transaccion_index`(`ID_Transaccion`);

-- Tabla OPINION
CREATE TABLE `OPINION`(
    `ID` INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `Calificación` TINYINT UNSIGNED NOT NULL,
    `ID_Transaccion` INT UNSIGNED NOT NULL,
    `ID_Producto` INT UNSIGNED NOT NULL,
    `Fecha` DATE NOT NULL,
    `Descripción` TEXT NOT NULL,
    `ID_Cliente` INT UNSIGNED NOT NULL
);
ALTER TABLE
    `OPINION` ADD INDEX `opinion_id_transaccion_index`(`ID_Transaccion`);
ALTER TABLE
    `OPINION` ADD INDEX `opinion_id_producto_index`(`ID_Producto`);
ALTER TABLE
    `OPINION` ADD INDEX `opinion_id_cliente_index`(`ID_Cliente`);

-- Tabla TRANSACCION
CREATE TABLE `TRANSACCION`(
    `ID_Transaccion` INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `Fecha` DATE NOT NULL,
    `ID_Cliente` INT UNSIGNED NOT NULL,
    `Estado` VARCHAR(50) NOT NULL,
    `Direccion_envio` VARCHAR(255) NOT NULL,
    `Pago` DECIMAL(10, 2) NOT NULL
);
ALTER TABLE
    `TRANSACCION` ADD INDEX `transaccion_id_cliente_index`(`ID_Cliente`);

-- Tabla DETALLES_TRANSACCION
CREATE TABLE `DETALLES_TRANSACCION`(
    `ID_Producto` INT UNSIGNED NOT NULL,
    `ID_Transaccion` INT UNSIGNED NULL,
    `Cantidad` INT NOT NULL,
    `Precio` DECIMAL(10, 2) NOT NULL,
    `Bruto` DECIMAL(10, 2) NOT NULL,
    `Impuesto` DECIMAL(10, 2) NOT NULL,
    `Neto` DECIMAL(10, 2) NOT NULL
);
ALTER TABLE
    `DETALLES_TRANSACCION` ADD INDEX `detalles_transaccion_id_producto_index`(`ID_Producto`);
ALTER TABLE
    `DETALLES_TRANSACCION` ADD INDEX `detalles_transaccion_id_transaccion_index`(`ID_Transaccion`);

-- Claves foráneas
ALTER TABLE
    `OPINION_CLIENTE` ADD CONSTRAINT `opinion_cliente_id_transaccion_foreign` FOREIGN KEY (`ID_Transaccion`) REFERENCES `TRANSACCION` (`ID_Transaccion`);
ALTER TABLE
    `DETALLES_TRANSACCION` ADD CONSTRAINT `detalles_transaccion_id_producto_foreign` FOREIGN KEY (`ID_Producto`) REFERENCES `PRODUCTO` (`ID_Producto`);
ALTER TABLE
    `PROVEDOR` ADD CONSTRAINT `provedor_id_transfefk_foreign` FOREIGN KEY (`ID_TransfeFK`) REFERENCES `TIPO_PROVEDOR` (`ID`);
ALTER TABLE
    `TRANSACCION` ADD CONSTRAINT `transaccion_id_cliente_foreign` FOREIGN KEY (`ID_Cliente`) REFERENCES `CLIENTE` (`ID_Cliente`);
ALTER TABLE
    `OPINION_CLIENTE` ADD CONSTRAINT `opinion_cliente_id_cliente_foreign` FOREIGN KEY (`ID_Cliente`) REFERENCES `CLIENTE` (`ID_Cliente`);
ALTER TABLE
    `OPINION` ADD CONSTRAINT `opinion_id_producto_foreign` FOREIGN KEY (`ID_Producto`) REFERENCES `PRODUCTO` (`ID_Producto`);
ALTER TABLE
    `OPINION` ADD CONSTRAINT `opinion_id_cliente_foreign` FOREIGN KEY (`ID_Cliente`) REFERENCES `CLIENTE` (`ID_Cliente`);
ALTER TABLE
    `USUARIO` ADD CONSTRAINT `usuario_rol_foreign` FOREIGN KEY (`Rol`) REFERENCES `ROLES` (`ID`);
