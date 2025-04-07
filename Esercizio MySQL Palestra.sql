-- DDL Data Definition Language
DROP DATABASE IF EXISTS Palestra;
CREATE DATABASE Palestra;
USE Palestra;

CREATE TABLE Segreteria (
     SegreteriaID INTEGER PRIMARY KEY AUTO_INCREMENT NOT NULL,
     Membro_Segreteria VARCHAR (250) NOT NULL,
     Email VARCHAR (250) NOT NULL,
     Pagamenti VARCHAR (250) NOT NULL,
     Ruolo ENUM ('Segreteria', 'Amministratore') NOT NULL
);

CREATE TABLE Cliente (
     ClienteID INTEGER PRIMARY KEY AUTO_INCREMENT NOT NULL,
     Nome VARCHAR (250) NOT NULL,
     Cognome VARCHAR (250) NOT NULL,
     Indirizzo VARCHAR (250) NOT NULL,
     cod_fis VARCHAR (16) NOT NULL UNIQUE,
     SegreteriaRIF INTEGER,
     FOREIGN KEY (SegreteriaRIF) REFERENCES Segreteria (SegreteriaID)
        ON DELETE SET NULL  -- Se cancello un operatore, i clienti restano senza assegnazione
        ON UPDATE CASCADE
);

CREATE TABLE Abbonamento (
     AbbonamentoID INTEGER PRIMARY KEY AUTO_INCREMENT NOT NULL, 
     Tipo ENUM ('Yoga', 'Sala Pesi', 'Pilates', 'Piscina'),
     Prezzo VARCHAR (250) NOT NULL,
     Durata ENUM ('Mensile', 'Trimestrale', 'Annuale', 'Premium'),
     ClienteRIF INTEGER NOT NULL,
     FOREIGN KEY (ClienteRIF) REFERENCES Cliente (ClienteID)
        ON DELETE CASCADE  -- Se cancello un membro, cancello il suo abbonamento
        ON UPDATE CASCADE,
     SegreteriaRIF INTEGER NOT NULL,
	 FOREIGN KEY (SegreteriaRIF) REFERENCES Segreteria (SegreteriaID)
        ON DELETE RESTRICT  -- Impedisce cancellazione se ha processato abbonamenti
        ON UPDATE CASCADE
);

CREATE TABLE Istruttore (
	 IstruttoreID INTEGER PRIMARY KEY AUTO_INCREMENT NOT NULL,
     Nome VARCHAR (250) NOT NULL,
     Cognome VARCHAR (250) NOT NULL,
     Specializzazione VARCHAR (250) NOT NULL,
     Certificato ENUM('Base', 'Avanzato', 'Master') DEFAULT 'Base'
);

CREATE TABLE Corso (
     CorsoID INTEGER PRIMARY KEY AUTO_INCREMENT NOT NULL,
	 Nome_Corso VARCHAR (250) NOT NULL,
     Orari TIME NOT NULL,
     Livello VARCHAR (250) NOT NULL,
     Massima_Capacità INT DEFAULT 20, 
     Durata_Corso INT DEFAULT 60,  
     Stanza VARCHAR (50),
     IstruttoreRIF INTEGER,
	 FOREIGN KEY (IstruttoreRIF) REFERENCES Istruttore(IstruttoreID)
        ON DELETE RESTRICT  -- Impedisce cancellazione se l'istruttore ha corsi assegnati
        ON UPDATE CASCADE   -- Se cambia l'ID dell'istruttore, si aggiorna automaticamente
);



CREATE TABLE Attrezzatura (
	 AttrezzaturaID INTEGER PRIMARY KEY AUTO_INCREMENT NOT NULL,
     Nome_Attrezzatura VARCHAR (250) NOT NULL,
     Stato ENUM ('Utilizzabile', 'In Manutenzione', 'Fuori Servizio') DEFAULT 'Utilizzabile',
     Data_Acquisto DATE,
	 Ultima_Manutenzione DATE
);

CREATE TABLE Cliente_Corso (
     ClienteRIF INTEGER NOT NULL,
     CorsoRIF INTEGER NOT NULL,
     FOREIGN KEY (ClienteRIF) REFERENCES Cliente (ClienteID) ON DELETE CASCADE,
     FOREIGN KEY (CorsoRIF) REFERENCES Corso (CorsoID) ON DELETE CASCADE,
     UNIQUE KEY Cliente_Corso (ClienteRIF, CorsoRIF)
);

CREATE TABLE Corso_Attrezzatura (
	 CorsoRIF INTEGER NOT NULL,
     AttrezzaturaRIF INTEGER NOT NULL,
     FOREIGN KEY (CorsoRIF) REFERENCES Corso (CorsoID) 
        ON DELETE CASCADE
        ON UPDATE CASCADE,
     FOREIGN KEY (AttrezzaturaRIF) REFERENCES Attrezzatura (AttrezzaturaID) 
	    ON DELETE RESTRICT -- Impedisce cancellazione se attrezzatura è in uso
        ON UPDATE CASCADE,
     UNIQUE KEY Corso_Attrezzatura (CorsoRIF, AttrezzaturaRIF)
);

INSERT INTO Segreteria (Membro_Segreteria, Email, Pagamenti, Ruolo) VALUES
('Mario Rossi', 'mario.rossi@example.com', 'PayPal', 'Segreteria'),
('Luca Bianchi', 'luca.bianchi@example.com', 'Carta di Credito', 'Amministratore');

INSERT INTO Cliente (Nome, Cognome, Indirizzo, cod_fis, SegreteriaRIF) VALUES
('Giulia Verdi', 'Verdi', 'Via Roma 10', 'VRDGLL99A45H501Z', 1),
('Andrea Neri', 'Neri', 'Corso Italia 25', 'NRANDR85B12E205Y', 2);

INSERT INTO Abbonamento (Tipo, Prezzo, Durata, ClienteRIF, SegreteriaRIF) VALUES
('Yoga', '50€', 'Mensile', 1, 1),
('Sala Pesi', '120€', 'Trimestrale', 2, 1);

INSERT INTO Istruttore (Nome, Cognome, Specializzazione, Certificato) VALUES
('Laura Bianchi', 'Bianchi', 'Yoga', 'Master'),
('Marco Rossi', 'Rossi', 'Sala Pesi', 'Avanzato');

INSERT INTO Corso (Nome_Corso, Orari, Livello, Stanza, IstruttoreRIF) VALUES
('Yoga Base', '10:00:00', 'Principiante', 'Sala 1', 1),
('Allenamento Funzionale', '18:30:00', 'Intermedio', 'Sala 2', 2);



INSERT INTO Attrezzatura (Nome_Attrezzatura, Stato, Data_Acquisto, Ultima_Manutenzione) VALUES
('Tapis Roulant', 'Utilizzabile', '2022-05-10', '2023-03-15'),
('Manubri', 'In Manutenzione', '2021-08-20', '2023-02-10');

INSERT INTO Cliente_Corso (ClienteRIF, CorsoRIF) VALUES
(1, 1),
(2, 2);

INSERT INTO Corso_Attrezzatura (CorsoRIF, AttrezzaturaRIF) VALUES
(2, 1),
(2, 2);

-- All'interno di questa query spieghiamo:
SELECT 
    Cliente.Nome AS Nome_Cliente, -- Nome del cliente 
    Cliente.Cognome AS Cognome_Cliente, --  Cognome del cliente
    Corso.Nome_Corso, -- Nome del corso che frequenta
    Istruttore.Nome AS Nome_Istruttore, -- Nome dell'istruttore che esegue il corso
    Istruttore.Cognome AS Cognome_Istruttore, -- Cognome dell'istruttore che esegue il corso
    Attrezzatura.Nome_Attrezzatura, -- Nome dell'attrezzatura
    Segreteria.Membro_Segreteria -- Membro che gestisce gli abbonamenti in segreteria
FROM Cliente
INNER JOIN Cliente_Corso ON Cliente.ClienteID = Cliente_Corso.ClienteRIF
INNER JOIN Corso ON Cliente_Corso.CorsoRIF = Corso.CorsoID
INNER JOIN Istruttore ON Corso.IstruttoreRIF = Istruttore.IstruttoreID
INNER JOIN Corso_Attrezzatura ON Corso.CorsoID = Corso_Attrezzatura.CorsoRIF
INNER JOIN Attrezzatura ON Corso_Attrezzatura.AttrezzaturaRIF = Attrezzatura.AttrezzaturaID
INNER JOIN Abbonamento ON Cliente.ClienteID = Abbonamento.ClienteRIF
INNER JOIN Segreteria ON Abbonamento.SegreteriaRIF = Segreteria.SegreteriaID;



