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
						ubicacion varchar(50) NOT NULL,
						equipamiento varchar(50) NOT NULL,       -- Describir los equipos con los que cuenta la sala, EJ: PROYECTORES
                        disponibilidad ENUM('Si', 'No') NOT NULL);                       -- Verificar si la sala estará libre u ocupada


-- Crear la tabla para Eventos
create table Eventos(id_evento int auto_increment primary key,
						nombre varchar(50) NOT NULL,       -- Nombre del evento
						descripcion varchar(50) NOT NULL,                          -- Descripcion del evento
                        fecha datetime NOT NULL,                                    -- Fecha en la que sera llevada a cabo el evento
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
                        evento_id int NOT NULL,    -- Clave foranea con la tabla Eventos
                        asistente_id int NOT NULL,   -- clave foranea con la tabla Usuarios
                        id_pago int NOT NULL,
                        estado enum('Pendiente', 'Cancelado', 'Confirmado') NOT NULL,
                        fecha_reserva datetime,
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


-- Implementación del cifrado de contraseñas
-- Se crea una columna en la tabla 
ALTER TABLE Usuarios ADD COLUMN Contrasenia_encriptada VARBINARY(255);

-- Insertar un usuario con contraseña cifrada
INSERT INTO Usuarios (nombres_completos, correo, Telefono, Rol, Contrasenia, Contrasenia_encriptada)  
VALUES ('Juan Pérez', 'juan.perez@mail.com', '123456789', 'Organizador', 'mi_password', AES_ENCRYPT('mi_password', 'clave_secreta'));

-- Recuperar y descifrar la contraseña para validación
SELECT nombres_completos, correo, 
       AES_DECRYPT(Contrasenia_encriptada, 'clave_secreta') AS Contrasenia_Descifrada 
FROM Usuarios;

-- Convertir el resultado a texto
-- Cambia la consulta para que MySQL convierta el resultado a CHAR:
SELECT nombres_completos, correo, 
       CONVERT(AES_DECRYPT(Contrasenia_encriptada, 'clave_secreta') USING utf8) AS Contrasenia_Descifrada 
FROM Usuarios;

-- Esta es la consulta general que muestra contraseña no encriptada y encriptada
SELECT id_usuario, nombres_completos, correo, Telefono, Rol, Contrasenia, Contrasenia_encriptada FROM Usuarios;

-- VISTAS
-- Esta vista muestra información detallada de los eventos, incluyendo el organizador y la sala donde se realizarán.
CREATE VIEW Vista_Eventos AS	
SELECT 								-- Facilita la consulta de eventos con información de la sala y organizador en una sola vista.

    e.id_evento,
    e.nombre AS nombre_evento,
    e.descripcion,
    e.fecha,
    e.hora_inicio,
    e.hora_fin,
    e.Estado,
    u.nombres_completos AS organizador,
    u.correo AS correo_organizador,
    s.nombre_sala,
    s.capacidad,
    s.ubicacion,
    s.equipamiento
FROM Eventos e
JOIN Usuarios u ON e.OrganizadorID = u.id_usuario
JOIN Salas s ON e.SalaID = s.id_sala;


CREATE VIEW Vista_Reservas AS
SELECT 
    r.id_reserva,
    r.fecha_reserva,
    r.estado AS estado_reserva,
    e.nombre AS nombre_evento,
    e.fecha AS fecha_evento,
    u.nombres_completos AS asistente,
    u.correo AS correo_asistente
FROM Reservas r
JOIN Eventos e ON r.evento_id = e.id_evento
JOIN Usuarios u ON r.asistente_id = u.id_usuario;


CREATE VIEW Vista_Pagos AS
SELECT 
    p.id_pago,
    p.Monto,
    p.Fecha_Pago,
    p.Metodo_Pago,
    u.nombres_completos AS asistente,
    u.correo AS correo_asistente,
    e.nombre AS nombre_evento,
    e.fecha AS fecha_evento
FROM Pagos p
JOIN Reservas r ON p.id_pago = r.id_pago
JOIN Usuarios u ON r.asistente_id = u.id_usuario
JOIN Eventos e ON r.evento_id = e.id_evento;

SELECT * FROM Vista_Eventos;
SELECT * FROM Vista_Reservas;
SELECT * FROM Vista_Pagos;


INSERT INTO Usuarios (nombres_completos, correo, Telefono, Rol, Contrasenia, Contrasenia_encriptada)
VALUES 
('Juan Pérez', 'juanito.roza@mail.com', '123456788', 'Organizador', 'password5', AES_ENCRYPT('password5', 'clave_secreta')),
('Ana Gómez', 'ana.gomez@mail.com', '987654321', 'Organizador', 'password2', AES_ENCRYPT('password2', 'clave_secreta')),
('Carlos Ruiz', 'carlos.ruiz@mail.com', '555666777', 'Asistente', 'password3', AES_ENCRYPT('password3', 'clave_secreta')),
('María López', 'maria.lopez@mail.com', '111222333', 'Asistente', 'password4', AES_ENCRYPT('password4', 'clave_secreta'));


INSERT INTO Salas (nombre_sala, capacidad, ubicacion, equipamiento, disponibilidad)
VALUES 
('Sala A', '100', '1er Piso', 'Proyector, Audio', 'Si'),
('Sala B', '50', '2do Piso', 'Pizarra, Sillas', 'Si');


INSERT INTO Eventos (nombre, descripcion, fecha, hora_inicio, hora_fin, Estado, SalaID, OrganizadorID)
VALUES 
('Conferencia Tech', 'Tecnología e innovación', '2025-02-10', '10:00:00', '12:00:00', 'Confirmado', 1, 1),
('Taller de IA', 'Aprendiendo sobre IA', '2025-02-15', '14:00:00', '16:00:00', 'Pendiente', 2, 2);

INSERT INTO Pagos (id_pago, Monto, Fecha_Pago, Metodo_Pago)
VALUES 
(3, 50.00, '2025-02-05', 'Tarjeta de Crédito'),
(4, 30.00, '2025-02-06', 'Transferencia');

INSERT INTO Reservas (evento_id, asistente_id, id_pago, estado, fecha_reserva)
VALUES 
(1, 3, 1, 'Confirmado', '2025-02-07'),
(2, 4, 2, 'Pendiente', '2025-02-08');


ALTER TABLE Salas MODIFY COLUMN capacidad INT;
-- Trigger para Encriptar Contraseñas Automáticamente
DELIMITER //

CREATE TRIGGER before_insert_usuario
BEFORE INSERT ON Usuarios
FOR EACH ROW
BEGIN
    SET NEW.Contrasenia_encriptada = AES_ENCRYPT(NEW.Contrasenia, 'clave_secreta');
END;

//

DELIMITER ;


-- Trigger para Validar la Capacidad de una Sala antes de Reservar
DELIMITER //

CREATE TRIGGER before_insert_reserva		-- Si un usuario cancela su reserva, se verifica cuántas reservas confirmadas quedan.
BEFORE INSERT ON Reservas					-- Si no quedan reservas, el evento se cancela automáticamente.
FOR EACH ROW
BEGIN
    DECLARE capacidad_actual INT;
    DECLARE max_capacidad INT;

    -- Obtener la cantidad de reservas confirmadas en el evento
    SELECT COUNT(*) INTO capacidad_actual
    FROM Reservas
    WHERE evento_id = NEW.evento_id AND estado = 'Confirmado';

    -- Obtener la capacidad máxima de la sala asociada al evento
    SELECT capacidad INTO max_capacidad
    FROM Salas
    WHERE id_sala = (SELECT SalaID FROM Eventos WHERE id_evento = NEW.evento_id);

    -- Validar que la capacidad no sea superada
    IF capacidad_actual >= max_capacidad THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Capacidad máxima de la sala alcanzada. No se puede realizar la reserva.';
    END IF;
END;
//

DELIMITER ;


-- Trigger para Registrar Pagos Automáticamente al Confirmar una Reserva
DELIMITER //						-- Al insertar una reserva, se genera un pago con monto 0.00 y estado "Pendiente".
									-- Luego, el usuario podrá actualizarlo con el monto y el método real de pago.
CREATE TRIGGER after_insert_reserva
AFTER INSERT ON Reservas
FOR EACH ROW
BEGIN
    INSERT INTO Pagos (Monto, Fecha_Pago, Metodo_Pago)
    VALUES (0.00, NOW(), 'Pendiente');
END;

//

DELIMITER ;



-- PROCEDIMIENTOS ALMACENADOS
-- Procedimiento para Registrar un Evento
DELIMITER //

CREATE PROCEDURE RegistrarEvento(
    IN p_nombre VARCHAR(50),
    IN p_descripcion VARCHAR(50),
    IN p_fecha DATETIME,
    IN p_hora_inicio TIME,
    IN p_hora_fin TIME,
    IN p_estado ENUM('Pendiente', 'Cancelado', 'Confirmado'),
    IN p_sala_id INT,
    IN p_organizador_id INT
)
BEGIN
    INSERT INTO Eventos (nombre, descripcion, fecha, hora_inicio, hora_fin, Estado, SalaID, OrganizadorID)
    VALUES (p_nombre, p_descripcion, p_fecha, p_hora_inicio, p_hora_fin, p_estado, p_sala_id, p_organizador_id);
END //

DELIMITER ;


-- Con este procedimiento, puedes agregar eventos fácilmente usando la siguiente sintaxis:
CALL RegistrarEvento('Conferencia sobre Seguridad', 'Aprender sobre seguridad informática', '2025-03-20', '09:00:00', '11:00:00', 'Confirmado', 1, 1);


-- Procedimiento para Actualizar el Estado de una Reserva
-- Este procedimiento cambia el estado de una reserva en función del id_reserva.
DELIMITER //

CREATE PROCEDURE ActualizarEstadoReserva(
    IN p_id_reserva INT,
    IN p_nuevo_estado ENUM('Pendiente', 'Cancelado', 'Confirmado')
)
BEGIN
    UPDATE Reservas
    SET estado = p_nuevo_estado
    WHERE id_reserva = p_id_reserva;
END //

DELIMITER ;

-- Y para ejecutarlo:
CALL ActualizarEstadoReserva(1, 'Confirmado');

-- Procedimiento para Registrar un Pago
-- Este procedimiento almacenado inserta un pago en la tabla Pagos.
DELIMITER //

CREATE PROCEDURE RegistrarPago(
    IN p_monto DECIMAL(10,2),
    IN p_metodo_pago VARCHAR(50)
)
BEGIN
    INSERT INTO Pagos (Monto, Fecha_Pago, Metodo_Pago)
    VALUES (p_monto, NOW(), p_metodo_pago);
END //

DELIMITER ;

-- Ejecucion no ejecute para probar 
CALL RegistrarPago(50.00, 'Tarjeta de Crédito');

-- Procedimiento para Verificar Disponibilidad de la Sala
-- Este procedimiento verifica si la sala está disponible para un evento en un rango de fechas.
DELIMITER //

CREATE PROCEDURE VerificarDisponibilidadSala(
    IN p_sala_id INT,
    IN p_fecha_inicio DATETIME,
    IN p_fecha_fin DATETIME
)
BEGIN
    DECLARE disponibilidad INT;
    
    SELECT COUNT(*) INTO disponibilidad
    FROM Eventos
    WHERE SalaID = p_sala_id
      AND ((fecha >= p_fecha_inicio AND fecha <= p_fecha_fin)
      OR (fecha BETWEEN p_fecha_inicio AND p_fecha_fin));
    
    IF disponibilidad > 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La sala no está disponible en este rango de fechas.';
    ELSE
        SELECT 'La sala está disponible.' AS mensaje;
    END IF;
END //

DELIMITER ;

-- Para verificar la disponibilidad de una sala:
CALL VerificarDisponibilidadSala(1, '2025-03-10 09:00:00', '2025-03-10 11:00:00');






