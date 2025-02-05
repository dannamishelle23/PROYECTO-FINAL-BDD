create database gestion_conferencias;
use gestion_conferencias;
-- Crear la tabla para usuarios con diferentes roles
create table Usuarios(id_usuario int auto_increment primary key,
						nombres_completos varchar(100) NOT NULL,
                        correo varchar(100) UNIQUE NOT NULL,
						Telefono varchar(50) UNIQUE NOT NULL,        -- El correo y el telefono deberán ser unicos para cada usuario
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
                        foreign key (OrganizadorID) references Usuarios(id_usuario));            -- Relacionar la columna OrganizadorID con la tabla Usuarios
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

alter table Salas add ubicacion varchar(50) NOT NULL;
-- Añadir la columna ubicacion en la tabla 'eventos'
alter table Eventos add descripcion varchar(50) NOT NULL;

drop table Reservas;

-- Crear la tabla para reservas
create table Reservas(id_reserva int auto_increment primary key,
                        evento_id int NOT NULL,    -- Clave foranea con la tabla Eventos
                        asistente_id int NOT NULL,
                        id_pago int NOT NULL,
                        id_usuario int NOT NULL,
                        estado enum('Pendiente', 'Cancelado', 'Confirmado') NOT NULL,
                        fecha_reserva datetime,
    			FOREIGN KEY (evento_ID) REFERENCES Eventos(id_evento),
    			FOREIGN KEY (asistente_id) REFERENCES Usuarios(id_usuario),
    			FOREIGN KEY (id_Pago) REFERENCES Pagos(id_pago)  -- Relación con el pago
);




-- ----------------------------------------------------------------------------------------

-- Definición de las restricciones de integridad referencial (eliminación - update).

-- 1. Usuarios - Eventos: ON DELETE SET NULL, ON UPDATE CASCADE
-- Si un usuario (organizador) es eliminado, su evento asociado tendrá el campo OrganizadorID 
-- establecido a NULL (no se elimina el evento).
-- Si un usuario es actualizado, el OrganizadorID en los eventos relacionados se actualizará automáticamente.

-- Modificar la tabla Eventos 
ALTER TABLE Eventos
DROP FOREIGN KEY eventos_ibfk_1, 
ADD CONSTRAINT fk_organizador_evento FOREIGN KEY (OrganizadorID) REFERENCES Usuarios(id_usuario)
ON DELETE SET NULL 
ON UPDATE CASCADE;

-- 2. Eventos - Reservas: ON DELETE CASCADE, ON UPDATE CASCADE
-- Si un evento es eliminado, todas las reservas asociadas a él se eliminarán automáticamente.
-- Si un evento es actualizado, las reservas asociadas se actualizarán automáticamente.

-- Modificar la tabla Reservas 
ALTER TABLE Reservas
DROP FOREIGN KEY reservas_ibfk_1,  
ADD CONSTRAINT fk_evento_reserva FOREIGN KEY (evento_id) REFERENCES Eventos(id_evento)
ON DELETE CASCADE 
ON UPDATE CASCADE;

-- 3. Usuarios - Reservas: ON DELETE CASCADE, ON UPDATE CASCADE
-- Si un usuario (asistente) es eliminado, sus reservas asociadas también serán eliminadas.
-- Si un usuario es actualizado, las reservas asociadas se actualizarán automáticamente.

-- Modificar la tabla Reservas 
ALTER TABLE Reservas
DROP FOREIGN KEY reservas_ibfk_2,  
ADD CONSTRAINT fk_asistente_reserva FOREIGN KEY (asistente_id) REFERENCES Usuarios(id_usuario)
ON DELETE CASCADE 
ON UPDATE CASCADE;

-- 4. Pagos - Reservas: ON DELETE RESTRICT, ON UPDATE CASCADE
-- No se puede eliminar un pago si está asociado a alguna reserva.
-- Si un pago es actualizado, la reserva relacionada se actualizará automáticamente.

-- Modificar la tabla Reservas 
ALTER TABLE Reservas
DROP FOREIGN KEY reservas_ibfk_3, 
ADD CONSTRAINT fk_pago_reserva FOREIGN KEY (id_pago) REFERENCES Pagos(id_pago)
ON DELETE RESTRICT 
ON UPDATE CASCADE;

-- 5. Usuarios - Usuarios_Salas: ON DELETE CASCADE, ON UPDATE CASCADE
-- Si un usuario es eliminado, todas sus asociaciones con salas (en la tabla intermedia Usuarios_Salas) serán eliminadas.
-- Si un usuario es actualizado, las asociaciones en Usuarios_Salas se actualizarán automáticamente.

-- Modificar la tabla Usuarios_Salas 
ALTER TABLE Usuarios_Salas
DROP FOREIGN KEY usuarios_salas_ibfk_1, 
ADD CONSTRAINT fk_usuario_sala FOREIGN KEY (id_usuario) REFERENCES Usuarios(id_usuario)
ON DELETE CASCADE 
ON UPDATE CASCADE;

-- 6. Salas - Usuarios_Salas: ON DELETE CASCADE, ON UPDATE CASCADE
-- Si una sala es eliminada, todas las asociaciones de usuarios con esa sala (en la tabla Usuarios_Salas) también serán eliminadas.
-- Si una sala es actualizada, las asociaciones en Usuarios_Salas se actualizarán automáticamente.

-- Modificar la tabla Usuarios_Salas 
ALTER TABLE Usuarios_Salas
DROP FOREIGN KEY usuarios_salas_ibfk_2,  
ADD CONSTRAINT fk_sala_usuario FOREIGN KEY (id_sala) REFERENCES Salas(id_sala)
ON DELETE CASCADE 
ON UPDATE CASCADE;

