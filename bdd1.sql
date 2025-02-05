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
                        asistente_id int NOT NULL,
                        id_pago int NOT NULL,
                        id_usuario int NOT NULL,
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
