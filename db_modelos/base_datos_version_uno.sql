-- =============================================================
--  BASE DE DATOS DISTRIBUIDA
--  Universidad Distrital Francisco José de Caldas
-- =============================================================
--
--  ARQUITECTURA DE NODOS:
--  NODO 1 - ud_chapinero  (SERVIDOR CENTRAL)
--    - Esquema global completo
--    - Nomina y contratacion (CLASIFICACION, DICTAR)
--    - Tabla PROFESOR completa (con datos salariales)
--    - Fragmento PREGRADO donde Sede = 'Chapinero'
--    - Vistas globales que unifican los tres nodos
--
--  NODO 2 - ud_macarena   (SERVIDOR LOCAL)
--    - Fragmento PREGRADO donde Sede = 'La Macarena'
--    - CURSO, GRUPO, ASIGNATURA de La Macarena
--    - PROFESOR_LOCAL: solo Nombre, E_Mail, Documento
--      (sin datos salariales - esos quedan en Chapinero)
--
--  NODO 3 - ud_ciudad_bolivar  (SERVIDOR LOCAL)
--    - Fragmento PREGRADO donde Sede = 'Ciudad Bolivar'
--    - CURSO, GRUPO, ASIGNATURA de Ciudad Bolivar
--    - PROFESOR_LOCAL: solo Nombre, E_Mail, Documento
--      (sin datos salariales - esos quedan en Chapinero)
--
--  TIPOS DE FRAGMENTACION:
--    Horizontal   -> PREGRADO, CURSO, GRUPO, ASIGNATURA (por Sede)
--    Vertical     -> PROFESOR (columnas distintas por nodo)
--    Mixta        -> ASIGNATURA (horizontal + vertical)
--    Centralizada -> CLASIFICACION, DICTAR (solo Chapinero)
-- =============================================================


-- ============================================================
-- NODO 1: ud_chapinero  -  SERVIDOR CENTRAL
-- ============================================================

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

-- PREGRADO: fragmento Chapinero (Sede = 'Chapinero')
-- Los demas fragmentos van en ud_macarena y ud_ciudad_bolivar
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

-- ASIGNATURA: fragmentacion MIXTA en Chapinero
--   Horizontal: solo asignaturas de pregrados de Chapinero
--   Vertical: Horas_Semanales replicada en nodos locales
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

-- PROFESOR: tabla COMPLETA solo en ud_chapinero
--   Fragmentacion vertical hacia nodos locales:
--     Nodos locales tienen: Numero_Documento, Nombre, E_Mail
--     Chapinero adiciona: Direccion, Categoria, Telefono
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

-- EDIFICIO: centralizada en ud_chapinero
CREATE TABLE EDIFICIO (
    Cod_Edificio  VARCHAR(10)   NOT NULL,
    Nombre        VARCHAR(100)  NOT NULL,
    Sede          VARCHAR(50)   NOT NULL,
    CONSTRAINT PK_EDIFICIO PRIMARY KEY (Cod_Edificio)
);

-- SALON: centralizada en ud_chapinero
CREATE TABLE SALON (
    Cod_Salon     VARCHAR(10)   NOT NULL,
    Numero_Salon  VARCHAR(10)   NOT NULL,
    Capacidad     INT           NOT NULL,
    Cod_Edificio  VARCHAR(10)   NOT NULL,
    CONSTRAINT PK_SALON      PRIMARY KEY (Cod_Salon),
    CONSTRAINT FK_SALON_EDIF FOREIGN KEY (Cod_Edificio)
        REFERENCES EDIFICIO(Cod_Edificio)
);

-- DICTAR: centralizada en ud_chapinero (gestion de nomina)
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
-- NODO 2: ud_macarena  -  SERVIDOR LOCAL LA MACARENA
-- ============================================================

CREATE DATABASE IF NOT EXISTS ud_macarena
    CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE ud_macarena;

-- Fragmentacion HORIZONTAL: filas donde Sede = 'La Macarena'
CREATE TABLE PREGRADO_MACARENA (
    Cod_Pregrado  VARCHAR(10)   NOT NULL,
    Nombre        VARCHAR(100)  NOT NULL,
    Creditos      INT           NOT NULL,
    Nota_Minima   DECIMAL(4,2)  NOT NULL,
    Sede          VARCHAR(50)   NOT NULL DEFAULT 'La Macarena',
    CONSTRAINT PK_PRE_MAC PRIMARY KEY (Cod_Pregrado)
);

CREATE TABLE CURSO_MACARENA (
    Cod_Pregrado_Curso    VARCHAR(15)  NOT NULL,
    Capacidad_Estudiantes INT          NOT NULL,
    CONSTRAINT PK_CUR_MAC PRIMARY KEY (Cod_Pregrado_Curso)
);

CREATE TABLE GRUPO_MACARENA (
    Cod_Grupo          VARCHAR(10)   NOT NULL,
    Cod_Pregrado_Curso VARCHAR(15)   NOT NULL,
    Curso              VARCHAR(100)  NOT NULL,
    Semestre           INT           NOT NULL,
    CONSTRAINT PK_GRU_MAC   PRIMARY KEY (Cod_Grupo),
    CONSTRAINT FK_GRU_CUR_M FOREIGN KEY (Cod_Pregrado_Curso)
        REFERENCES CURSO_MACARENA(Cod_Pregrado_Curso)
);

-- Fragmentacion MIXTA: horizontal (La Macarena) + vertical
-- (Horas_Semanales replicada para consultas sin ir a Chapinero)
CREATE TABLE ASIGNATURA_MACARENA (
    Cod_Asignatura    VARCHAR(10)   NOT NULL,
    Nombre_Asignatura VARCHAR(100)  NOT NULL,
    Cod_Pregrado      VARCHAR(10)   NOT NULL,
    Cod_Curso         VARCHAR(15)   NOT NULL,
    Horas_Semanales   INT           NOT NULL,
    CONSTRAINT PK_ASI_MAC   PRIMARY KEY (Cod_Asignatura),
    CONSTRAINT FK_ASI_PRE_M FOREIGN KEY (Cod_Pregrado)
        REFERENCES PREGRADO_MACARENA(Cod_Pregrado),
    CONSTRAINT FK_ASI_CUR_M FOREIGN KEY (Cod_Curso)
        REFERENCES CURSO_MACARENA(Cod_Pregrado_Curso)
);

-- Fragmentacion VERTICAL de PROFESOR
-- Presentes: Numero_Documento, Nombre, E_Mail
-- Ausentes (solo en Chapinero): Direccion, Categoria, Telefono
CREATE TABLE PROFESOR_LOCAL_MACARENA (
    Numero_Documento  VARCHAR(20)   NOT NULL,
    Nombre            VARCHAR(100)  NOT NULL,
    E_Mail            VARCHAR(100)  NOT NULL,
    CONSTRAINT PK_PRO_MAC PRIMARY KEY (Numero_Documento)
);


-- ============================================================
-- NODO 3: ud_ciudad_bolivar  -  SERVIDOR LOCAL CIUDAD BOLIVAR
-- ============================================================

CREATE DATABASE IF NOT EXISTS ud_ciudad_bolivar
    CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE ud_ciudad_bolivar;

-- Fragmentacion HORIZONTAL: filas donde Sede = 'Ciudad Bolivar'
CREATE TABLE PREGRADO_BOLIVAR (
    Cod_Pregrado  VARCHAR(10)   NOT NULL,
    Nombre        VARCHAR(100)  NOT NULL,
    Creditos      INT           NOT NULL,
    Nota_Minima   DECIMAL(4,2)  NOT NULL,
    Sede          VARCHAR(50)   NOT NULL DEFAULT 'Ciudad Bolivar',
    CONSTRAINT PK_PRE_BOL PRIMARY KEY (Cod_Pregrado)
);

CREATE TABLE CURSO_BOLIVAR (
    Cod_Pregrado_Curso    VARCHAR(15)  NOT NULL,
    Capacidad_Estudiantes INT          NOT NULL,
    CONSTRAINT PK_CUR_BOL PRIMARY KEY (Cod_Pregrado_Curso)
);

CREATE TABLE GRUPO_BOLIVAR (
    Cod_Grupo          VARCHAR(10)   NOT NULL,
    Cod_Pregrado_Curso VARCHAR(15)   NOT NULL,
    Curso              VARCHAR(100)  NOT NULL,
    Semestre           INT           NOT NULL,
    CONSTRAINT PK_GRU_BOL   PRIMARY KEY (Cod_Grupo),
    CONSTRAINT FK_GRU_CUR_B FOREIGN KEY (Cod_Pregrado_Curso)
        REFERENCES CURSO_BOLIVAR(Cod_Pregrado_Curso)
);

-- Fragmentacion MIXTA: horizontal (Ciudad Bolivar) + vertical
CREATE TABLE ASIGNATURA_BOLIVAR (
    Cod_Asignatura    VARCHAR(10)   NOT NULL,
    Nombre_Asignatura VARCHAR(100)  NOT NULL,
    Cod_Pregrado      VARCHAR(10)   NOT NULL,
    Cod_Curso         VARCHAR(15)   NOT NULL,
    Horas_Semanales   INT           NOT NULL,
    CONSTRAINT PK_ASI_BOL   PRIMARY KEY (Cod_Asignatura),
    CONSTRAINT FK_ASI_PRE_B FOREIGN KEY (Cod_Pregrado)
        REFERENCES PREGRADO_BOLIVAR(Cod_Pregrado),
    CONSTRAINT FK_ASI_CUR_B FOREIGN KEY (Cod_Curso)
        REFERENCES CURSO_BOLIVAR(Cod_Pregrado_Curso)
);

-- Fragmentacion VERTICAL de PROFESOR
-- Presentes: Numero_Documento, Nombre, E_Mail
-- Ausentes (solo en Chapinero): Direccion, Categoria, Telefono
CREATE TABLE PROFESOR_LOCAL_BOLIVAR (
    Numero_Documento  VARCHAR(20)   NOT NULL,
    Nombre            VARCHAR(100)  NOT NULL,
    E_Mail            VARCHAR(100)  NOT NULL,
    CONSTRAINT PK_PRO_BOL PRIMARY KEY (Numero_Documento)
);


-- ============================================================
-- VISTAS GLOBALES - En ud_chapinero (nodo central)
-- ============================================================

USE ud_chapinero;

-- V_PREGRADO_GLOBAL: une fragmentos de las tres sedes
CREATE OR REPLACE VIEW V_PREGRADO_GLOBAL AS
    SELECT Cod_Pregrado, Nombre, Creditos, Nota_Minima, Sede
    FROM PREGRADO WHERE Sede = 'Chapinero'
  UNION ALL
    SELECT Cod_Pregrado, Nombre, Creditos, Nota_Minima, Sede
    FROM PREGRADO WHERE Sede = 'La Macarena'
  UNION ALL
    SELECT Cod_Pregrado, Nombre, Creditos, Nota_Minima, Sede
    FROM PREGRADO WHERE Sede = 'Ciudad Bolivar';

-- V_CARGA_DOCENTE: nomina completa (solo ud_chapinero)
CREATE OR REPLACE VIEW V_CARGA_DOCENTE AS
    SELECT pr.Nombre AS Profesor, pr.E_Mail,
           cl.Categoria, cl.Sueldo,
           a.Nombre_Asignatura, d.N_Horas, pg.Sede
    FROM DICTAR d
    JOIN PROFESOR      pr ON d.Cod_Profesor   = pr.Numero_Documento
    JOIN CLASIFICACION cl ON pr.Categoria     = cl.Categoria
    JOIN ASIGNATURA    a  ON d.Cod_Asignatura = a.Cod_Asignatura
    JOIN PREGRADO      pg ON a.Cod_Pregrado   = pg.Cod_Pregrado;

-- V_PROFESOR_PUBLICO: sin datos salariales (consultable desde nodos)
CREATE OR REPLACE VIEW V_PROFESOR_PUBLICO AS
    SELECT Numero_Documento, Nombre, E_Mail FROM PROFESOR;


-- ============================================================
-- DATOS DE PRUEBA
-- ============================================================

USE ud_chapinero;

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

-- Replicar fragmentos a nodos locales
INSERT INTO ud_macarena.PREGRADO_MACARENA
    SELECT * FROM PREGRADO WHERE Sede='La Macarena';
INSERT INTO ud_ciudad_bolivar.PREGRADO_BOLIVAR
    SELECT * FROM PREGRADO WHERE Sede='Ciudad Bolivar';
INSERT INTO ud_macarena.PROFESOR_LOCAL_MACARENA
    SELECT Numero_Documento,Nombre,E_Mail FROM PROFESOR;
INSERT INTO ud_ciudad_bolivar.PROFESOR_LOCAL_BOLIVAR
    SELECT Numero_Documento,Nombre,E_Mail FROM PROFESOR;

-- Consultas de verificacion
SELECT * FROM V_PREGRADO_GLOBAL ORDER BY Sede;
SELECT * FROM V_CARGA_DOCENTE;
SELECT pg.Sede, pg.Nombre,
       COUNT(a.Cod_Asignatura) AS Total_Asignaturas,
       SUM(a.Horas_Semanales)  AS Total_Horas_Semana
FROM PREGRADO pg
LEFT JOIN ASIGNATURA a ON pg.Cod_Pregrado=a.Cod_Pregrado
GROUP BY pg.Sede, pg.Nombre ORDER BY pg.Sede;

-- FIN DEL SCRIPT
