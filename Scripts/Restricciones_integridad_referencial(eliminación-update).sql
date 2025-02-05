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

