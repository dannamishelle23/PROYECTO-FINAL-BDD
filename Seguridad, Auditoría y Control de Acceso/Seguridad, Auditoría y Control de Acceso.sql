create database gestion_conferencias;
use gestion_conferencias;
-- Crear la tabla para usuarios con diferentes roles
create table Usuarios(id_usuario int auto_increment primary key,
						nombres_completos varchar(100) NOT NULL,
                        correo varchar(100) UNIQUE NOT NULL,
						Telefono varchar(50) UNIQUE NOT NULL,	-- El correo y el telefono deberán ser unicos para cada usuario
                        Rol ENUM('Invitado', 'Organizador', 'Asistente', 'Administrador') NOT NULL,
                        Contrasenia varchar(255) NOT NULL);
-- Crear la tabla para salas
create table Salas(id_sala int auto_increment primary key,
						nombre_sala varchar(60) NOT NULL,
                        capacidad varchar(100) NOT NULL,
						equipamiento varchar(50) NOT NULL,
                        disponibilidad ENUM('Si', 'No') NOT NULL);

-- Crear la tabla para Eventos
create table Eventos(id_evento int auto_increment primary key,
						nombre varchar(50) NOT NULL,
                        fecha datetime NOT NULL,
						hora_inicio time NOT NULL,
                        hora_fin time NOT NULL,
                        Estado enum('Pendiente', 'Cancelado', 'Confirmado') NOT NULL,
                        SalaID int,
                        OrganizadorID int,
                        foreign key (OrganizadorID) references Usuarios(id_usuario));	-- Relacionar la columna OrganizadorID con la tabla Usuarios
-- Crear la tabla Pagos
CREATE TABLE Pagos (
    id_pago INT PRIMARY KEY,  -- ID único para el pago
    Monto DECIMAL(10, 2),  -- Monto del pago
    Fecha_Pago DATE,  -- Fecha en que se realizó el pago
    Metodo_Pago VARCHAR(50)  -- Método de pago (tarjeta, transferencia, etc.)
);

-- Crear la tabla para reservas
create table Reservas(id_reserva int auto_increment primary key,
						sala_id int NOT NULL,
                        evento_id int NOT NULL,
                        asistente_id int NOT NULL,
                        id_pago int NOT NULL,
                        id_usuario int NOT NULL,
                        estado enum('Pendiente', 'Cancelado', 'Confirmado') NOT NULL,
                        fecha_reserva datetime,
                         FOREIGN KEY (Sala_ID) REFERENCES Salas(ID_Sala),
    FOREIGN KEY (evento_ID) REFERENCES Eventos(id_evento),
    FOREIGN KEY (asistente_id) REFERENCES Usuarios(id_usuario),
    FOREIGN KEY (id_Pago) REFERENCES Pagos(id_pago)  -- Relación con el pago
);

-- Crear una tabla intermedia Usuarios_Salas para que un usuario este a cargo de varias salas
CREATE TABLE Usuarios_Salas (
    id int auto_increment primary key,
    id_usuario INT,
    id_sala INT,
    trabajo VARCHAR(50),  -- Ejemplo: "Administrador", "Soporte técnico"
    FOREIGN KEY (id_usuario) REFERENCES Usuarios(id_usuario),
    FOREIGN KEY (id_sala) REFERENCES Salas(id_sala)
);

-- Añadir la columna ubicacion en la tabla 'Salas'
alter table Salas add ubicacion varchar(50) NOT NULL;

 
 -- Implementación de políticas de acceso y seguridad.

CREATE ROLE 'Invitado';
CREATE ROLE 'Organizador';
CREATE ROLE 'Asistente';
CREATE ROLE 'Administrador';

-- El rol de Invitado: Solo le permite ver eventos y salas
GRANT SELECT ON gestion_conferencias.Eventos TO 'Invitado';
GRANT SELECT ON gestion_conferencias.Salas TO 'Invitado';

-- el rol de Organizador: le permite crear, modificar y eliminar eventos, y gestionar salas
GRANT ALL PRIVILEGES ON gestion_conferencias.Eventos TO 'Organizador';
GRANT ALL PRIVILEGES ON gestion_conferencias.Salas TO 'Organizador';

-- el rol de sistente: le permite realizar reservar eventos y ver su información
GRANT SELECT, INSERT, UPDATE ON gestion_conferencias.Reservas TO 'Asistente';
GRANT SELECT ON gestion_conferencias.Eventos TO 'Asistente';

-- y por ultimo el rol de dministrador: no tiene restricciones, tiene todos los permisos..
GRANT ALL PRIVILEGES ON gestion_conferencias.* TO 'Administrador';

 
 -- Habilitar auditoría y registrar eventos. 

SET GLOBAL general_log = 'ON';
SET GLOBAL general_log_file = 'C:\Program Files\MySQL\MySQL\log\general.log';

SET GLOBAL slow_query_log = 'ON';
SET GLOBAL slow_query_log_file = 'C:\Program Files\MySQL\MySQL\log\slow.log';
SET GLOBAL long_query_time = 2; -- Registra consultas que tarden más de 2 segundos

CREATE TABLE Auditoria (
    id_auditoria INT AUTO_INCREMENT PRIMARY KEY,
    id_usuario INT,
    accion VARCHAR(100),
    tabla_afectada VARCHAR(100),
    fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_usuario) REFERENCES Usuarios(id_usuario)
);

DELIMITER //
CREATE TRIGGER after_insert_eventos
AFTER INSERT ON Eventos
FOR EACH ROW
BEGIN
    INSERT INTO Auditoria (id_usuario, accion, tabla_afectada)
    VALUES (NEW.OrganizadorID, 'INSERT', 'Eventos');
END//
DELIMITER ;

DELIMITER //
CREATE TRIGGER after_update_eventos
AFTER UPDATE ON Eventos
FOR EACH ROW
BEGIN
    INSERT INTO Auditoria (id_usuario, accion, tabla_afectada)
    VALUES (NEW.OrganizadorID, 'UPDATE', 'Eventos');
END//
DELIMITER ;

DELIMITER //

CREATE TRIGGER after_delete_eventos
AFTER DELETE ON Eventos
FOR EACH ROW
BEGIN
    INSERT INTO Auditoria (id_usuario, accion, tabla_afectada)
    VALUES (OLD.OrganizadorID, 'DELETE', 'Eventos');
END//
DELIMITER ;
