CREATE TABLE autores (
  id INT AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(80) NOT NULL,
  pais CHAR(2) NOT NULL,
  fecha_nacimiento DATE,
  activo BOOLEAN DEFAULT TRUE,
  calificacion DECIMAL(3,2),
  biografia TEXT
);

CREATE TABLE libros (
  id INT AUTO_INCREMENT PRIMARY KEY,
  autor_id INT NOT NULL,
  titulo VARCHAR(150) NOT NULL,
  isbn CHAR(13) NOT NULL,
  fecha_publicacion DATE,
  disponible BOOLEAN DEFAULT TRUE,
  precio DECIMAL(10,2),
  CONSTRAINT fk_libros_autor FOREIGN KEY (autor_id) REFERENCES autores(id) ON DELETE RESTRICT
);

INSERT INTO autores (nombre, pais, fecha_nacimiento, activo, calificacion, biografia) VALUES
('Gabriel García Márquez','CO','1927-03-06',FALSE,4.90,'Premio Nobel de Literatura 1982'),
('Isabel Allende','CL','1942-08-02',TRUE,4.70,'Novelista chilena'),
('Julio Cortázar','AR','1914-08-26',FALSE,4.80,'Autor de Rayuela'),
('Laura Restrepo','CO','1950-02-27',TRUE,4.50,'Escritora colombiana'),
('Mario Vargas Llosa','PE','1936-03-28',FALSE,4.60,'Premio Nobel 2010');