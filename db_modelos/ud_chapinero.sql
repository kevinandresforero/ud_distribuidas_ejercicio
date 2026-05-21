-- =============================================================
--  NODO 1: ud_chapinero  -  SERVIDOR CENTRAL
--  Esquema global completo con todos los datos
-- =============================================================

CREATE DATABASE IF NOT EXISTS ud_chapinero
    CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE ud_chapinero;

-- CLASIFICACION: solo existe en ud_chapinero (nomina)
CREATE TABLE CLASIFICACION (
    Categoria            VARCHAR(50)    NOT NULL,
    Numero_Maximo_Horas  INT            NOT NULL,
    Sueldo               DECIMAL(12,2)  NOT NULL,
    CONSTRAINT PK_CLASIFICACION PRIMARY KEY (Categoria)
);

-- PREGRADO: tabla completa (todas las sedes)
CREATE TABLE PREGRADO (
    Cod_Pregrado  VARCHAR(10)   NOT NULL,
    Nombre        VARCHAR(100)  NOT NULL,
    Creditos      INT           NOT NULL,
    Nota_Minima   DECIMAL(4,2)  NOT NULL,
    Sede          VARCHAR(50)   NOT NULL
        CHECK (Sede IN ('Chapinero','La Macarena','Ciudad Bolivar')),
    CONSTRAINT PK_PREGRADO PRIMARY KEY (Cod_Pregrado)
);

CREATE TABLE CURSO (
    Cod_Pregrado_Curso    VARCHAR(15)  NOT NULL,
    Capacidad_Estudiantes INT          NOT NULL,
    CONSTRAINT PK_CURSO PRIMARY KEY (Cod_Pregrado_Curso)
);

CREATE TABLE GRUPO (
    Cod_Grupo          VARCHAR(10)   NOT NULL,
    Cod_Pregrado_Curso VARCHAR(15)   NOT NULL,
    Curso              VARCHAR(100)  NOT NULL,
    Semestre           INT           NOT NULL,
    CONSTRAINT PK_GRUPO       PRIMARY KEY (Cod_Grupo),
    CONSTRAINT FK_GRUPO_CURSO FOREIGN KEY (Cod_Pregrado_Curso)
        REFERENCES CURSO(Cod_Pregrado_Curso)
);

CREATE TABLE ASIGNATURA (
    Cod_Asignatura    VARCHAR(10)   NOT NULL,
    Nombre_Asignatura VARCHAR(100)  NOT NULL,
    Cod_Pregrado      VARCHAR(10)   NOT NULL,
    Cod_Curso         VARCHAR(15)   NOT NULL,
    Horas_Semanales   INT           NOT NULL,
    CONSTRAINT PK_ASIGNATURA    PRIMARY KEY (Cod_Asignatura),
    CONSTRAINT FK_ASIG_PREGRADO FOREIGN KEY (Cod_Pregrado)
        REFERENCES PREGRADO(Cod_Pregrado),
    CONSTRAINT FK_ASIG_CURSO    FOREIGN KEY (Cod_Curso)
        REFERENCES CURSO(Cod_Pregrado_Curso)
);

CREATE TABLE PROFESOR (
    Numero_Documento  VARCHAR(20)   NOT NULL,
    Nombre            VARCHAR(100)  NOT NULL,
    Direccion         VARCHAR(150),
    Categoria         VARCHAR(50)   NOT NULL,
    Telefono          VARCHAR(20),
    E_Mail            VARCHAR(100)  NOT NULL,
    CONSTRAINT PK_PROFESOR   PRIMARY KEY (Numero_Documento),
    CONSTRAINT FK_PROF_CLAS  FOREIGN KEY (Categoria)
        REFERENCES CLASIFICACION(Categoria)
);

CREATE TABLE EDIFICIO (
    Cod_Edificio  VARCHAR(10)   NOT NULL,
    Nombre        VARCHAR(100)  NOT NULL,
    Sede          VARCHAR(50)   NOT NULL,
    CONSTRAINT PK_EDIFICIO PRIMARY KEY (Cod_Edificio)
);

CREATE TABLE SALON (
    Cod_Salon     VARCHAR(10)   NOT NULL,
    Numero_Salon  VARCHAR(10)   NOT NULL,
    Capacidad     INT           NOT NULL,
    Cod_Edificio  VARCHAR(10)   NOT NULL,
    CONSTRAINT PK_SALON      PRIMARY KEY (Cod_Salon),
    CONSTRAINT FK_SALON_EDIF FOREIGN KEY (Cod_Edificio)
        REFERENCES EDIFICIO(Cod_Edificio)
);

CREATE TABLE DICTAR (
    Cod_Asignatura  VARCHAR(10)  NOT NULL,
    Cod_Profesor    VARCHAR(20)  NOT NULL,
    Cod_Salon       VARCHAR(10)  NOT NULL,
    N_Horas         INT          NOT NULL,
    CONSTRAINT PK_DICTAR       PRIMARY KEY (Cod_Asignatura, Cod_Profesor),
    CONSTRAINT FK_DICTAR_ASIG  FOREIGN KEY (Cod_Asignatura)
        REFERENCES ASIGNATURA(Cod_Asignatura),
    CONSTRAINT FK_DICTAR_PROF  FOREIGN KEY (Cod_Profesor)
        REFERENCES PROFESOR(Numero_Documento),
    CONSTRAINT FK_DICTAR_SALON FOREIGN KEY (Cod_Salon)
        REFERENCES SALON(Cod_Salon)
);

-- ============================================================
-- VISTAS GLOBALES
-- ============================================================

CREATE OR REPLACE VIEW V_PREGRADO_GLOBAL AS
    SELECT Cod_Pregrado, Nombre, Creditos, Nota_Minima, Sede
    FROM PREGRADO WHERE Sede = 'Chapinero'
  UNION ALL
    SELECT Cod_Pregrado, Nombre, Creditos, Nota_Minima, Sede
    FROM PREGRADO WHERE Sede = 'La Macarena'
  UNION ALL
    SELECT Cod_Pregrado, Nombre, Creditos, Nota_Minima, Sede
    FROM PREGRADO WHERE Sede = 'Ciudad Bolivar';

CREATE OR REPLACE VIEW V_CARGA_DOCENTE AS
    SELECT pr.Nombre AS Profesor, pr.E_Mail,
           cl.Categoria, cl.Sueldo,
           a.Nombre_Asignatura, d.N_Horas, pg.Sede
    FROM DICTAR d
    JOIN PROFESOR      pr ON d.Cod_Profesor   = pr.Numero_Documento
    JOIN CLASIFICACION cl ON pr.Categoria     = cl.Categoria
    JOIN ASIGNATURA    a  ON d.Cod_Asignatura = a.Cod_Asignatura
    JOIN PREGRADO      pg ON a.Cod_Pregrado   = pg.Cod_Pregrado;

CREATE OR REPLACE VIEW V_PROFESOR_PUBLICO AS
    SELECT Numero_Documento, Nombre, E_Mail FROM PROFESOR;

-- ============================================================
-- DATOS DE PRUEBA
-- ============================================================

INSERT INTO CLASIFICACION VALUES
    ('Auxiliar',16,2800000),('Asistente',20,3500000),
    ('Asociado',24,4500000),('Titular',28,6000000);

INSERT INTO EDIFICIO VALUES
    ('EDIF-001','Edificio A','Chapinero'),
    ('EDIF-002','Edificio B','La Macarena'),
    ('EDIF-003','Edificio C','Ciudad Bolivar');

INSERT INTO SALON VALUES
    ('SAL-001','101',40,'EDIF-001'),
    ('SAL-002','102',35,'EDIF-001'),
    ('SAL-003','201',45,'EDIF-002'),
    ('SAL-004','202',30,'EDIF-002'),
    ('SAL-005','301',25,'EDIF-003'),
    ('SAL-006','302',50,'EDIF-003');

INSERT INTO PREGRADO VALUES
    ('ING-001','Ingenieria de Sistemas',160,3.0,'Chapinero'),
    ('ING-002','Ingenieria Electronica',158,3.0,'Chapinero'),
    ('ADM-001','Administracion de Empresas',148,3.0,'La Macarena'),
    ('DER-001','Derecho',170,3.0,'La Macarena'),
    ('LIC-001','Licenciatura en Educacion',155,3.0,'Ciudad Bolivar'),
    ('ART-001','Artes Visuales',140,3.0,'Ciudad Bolivar');

INSERT INTO CURSO VALUES
    ('ING001-BD',35),('ING001-POO',40),('ADM001-ADM',45),
    ('DER001-CON',50),('LIC001-PED',30),('ART001-DIS',25);

INSERT INTO GRUPO VALUES
    ('G-001','ING001-BD','Bases de Datos I',1),
    ('G-002','ING001-POO','Prog Orientada Objetos',2),
    ('G-003','ADM001-ADM','Fund de Administracion',1),
    ('G-004','DER001-CON','Derecho Constitucional',1),
    ('G-005','LIC001-PED','Pedagogia General',2),
    ('G-006','ART001-DIS','Diseno Basico',1);

INSERT INTO ASIGNATURA VALUES
    ('ASG-001','Bases de Datos I','ING-001','ING001-BD',4),
    ('ASG-002','Prog Orientada Objetos','ING-001','ING001-POO',4),
    ('ASG-003','Fund de Administracion','ADM-001','ADM001-ADM',3),
    ('ASG-004','Derecho Constitucional','DER-001','DER001-CON',4),
    ('ASG-005','Pedagogia General','LIC-001','LIC001-PED',3),
    ('ASG-006','Diseno Basico','ART-001','ART001-DIS',5);

INSERT INTO PROFESOR VALUES
    ('12345678','Carlos Rodriguez','Calle 45 #12-34','Titular','3001234567','c.rodriguez@udistrital.edu.co'),
    ('23456789','Maria Gonzalez','Carrera 7 #89-01','Asociado','3019876543','m.gonzalez@udistrital.edu.co'),
    ('34567890','Jorge Martinez','Av Americas #50','Asistente','3104567890','j.martinez@udistrital.edu.co'),
    ('45678901','Laura Perez','Calle 80 #22-11','Auxiliar','3201239876','l.perez@udistrital.edu.co');

INSERT INTO DICTAR VALUES
    ('ASG-001','12345678','SAL-001',4),('ASG-002','23456789','SAL-002',4),
    ('ASG-003','34567890','SAL-003',3),('ASG-004','12345678','SAL-004',4),
    ('ASG-005','45678901','SAL-005',3),('ASG-006','34567890','SAL-006',5);

-- ============================================================
-- DATOS DE PRUEBA ADICIONALES
-- ============================================================

-- Mas categorias
INSERT INTO CLASIFICACION VALUES
    ('Catedratico',12,2000000),('Instructor',10,1500000);

-- Mas edificios
INSERT INTO EDIFICIO VALUES
    ('EDIF-004','Edificio D','Chapinero'),
    ('EDIF-005','Edificio E','La Macarena'),
    ('EDIF-006','Edificio F','Ciudad Bolivar');

-- Mas salones
INSERT INTO SALON VALUES
    ('SAL-007','103',30,'EDIF-004'),
    ('SAL-008','104',35,'EDIF-004'),
    ('SAL-009','203',40,'EDIF-005'),
    ('SAL-010','204',30,'EDIF-005'),
    ('SAL-011','303',25,'EDIF-006'),
    ('SAL-012','304',50,'EDIF-006');

-- Mas pregrados
INSERT INTO PREGRADO VALUES
    ('ING-003','Ingenieria Civil',162,3.0,'Chapinero'),
    ('ING-004','Ingenieria Industrial',160,3.0,'Chapinero'),
    ('ECO-001','Economia',150,3.0,'La Macarena'),
    ('PSI-001','Psicologia',165,3.0,'La Macarena'),
    ('SOC-001','Sociologia',152,3.0,'Ciudad Bolivar'),
    ('TEC-001','Tecnologia en Alimentos',145,3.0,'Ciudad Bolivar');

-- Mas cursos
INSERT INTO CURSO VALUES
    ('ING001-CAL',30),('ING001-FIS',35),
    ('ECO001-MIC',40),('PSI001-GEN',30),
    ('SOC001-INV',35),('TEC001-ALI',25);

-- Mas grupos
INSERT INTO GRUPO VALUES
    ('G-007','ING001-CAL','Calculo I',1),
    ('G-008','ING001-FIS','Fisica I',2),
    ('G-009','ECO001-MIC','Microeconomia',1),
    ('G-010','PSI001-GEN','Psicologia General',2),
    ('G-011','SOC001-INV','Investigacion Social',1),
    ('G-012','TEC001-ALI','Tecnologia de Alimentos',1);

-- Mas asignaturas
INSERT INTO ASIGNATURA VALUES
    ('ASG-007','Calculo I','ING-003','ING001-CAL',5),
    ('ASG-008','Fisica I','ING-004','ING001-FIS',4),
    ('ASG-009','Microeconomia','ECO-001','ECO001-MIC',4),
    ('ASG-010','Psicologia General','PSI-001','PSI001-GEN',3),
    ('ASG-011','Investigacion Social','SOC-001','SOC001-INV',3),
    ('ASG-012','Tecnologia de Alimentos','TEC-001','TEC001-ALI',5);

-- Mas profesores
INSERT INTO PROFESOR VALUES
    ('56789012','Ana Torres','Calle 10 #5-67','Asociado','3112345678','a.torres@udistrital.edu.co'),
    ('67890123','Pedro Ramirez','Carrera 15 #30-20','Asistente','3123456789','p.ramirez@udistrital.edu.co'),
    ('78901234','Diana Lopez','Av El Dorado #68-90','Titular','3134567890','d.lopez@udistrital.edu.co'),
    ('89012345','Santiago Herrera','Calle 26 #13-45','Auxiliar','3145678901','s.herrera@udistrital.edu.co');

-- Mas dictar
INSERT INTO DICTAR VALUES
    ('ASG-007','56789012','SAL-007',5),('ASG-008','67890123','SAL-008',4),
    ('ASG-009','56789012','SAL-009',4),('ASG-010','78901234','SAL-010',3),
    ('ASG-011','89012345','SAL-011',3),('ASG-012','78901234','SAL-012',5);

-- ============================================================
-- CONSULTAS DE VERIFICACION
-- ============================================================


SELECT * FROM V_PREGRADO_GLOBAL ORDER BY Sede;


SELECT * FROM V_CARGA_DOCENTE;


SELECT pg.Sede, pg.Nombre,
       COUNT(a.Cod_Asignatura) AS Total_Asignaturas,
       SUM(a.Horas_Semanales)  AS Total_Horas_Semana
FROM PREGRADO pg
LEFT JOIN ASIGNATURA a ON pg.Cod_Pregrado = a.Cod_Pregrado
GROUP BY pg.Sede, pg.Nombre ORDER BY pg.Sede;

-- FIN DEL SCRIPT
