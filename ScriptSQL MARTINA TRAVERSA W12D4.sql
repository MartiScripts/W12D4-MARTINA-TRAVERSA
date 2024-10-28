-- Creazione tabelle
CREATE TABLE Category (
    CategoryID INT PRIMARY KEY,
    CategoryName VARCHAR(100) NOT NULL
);

CREATE TABLE Product (
    ProductID INT PRIMARY KEY,
    ProductName VARCHAR(100) NOT NULL,
    CategoryID INT,
    FOREIGN KEY (CategoryID) REFERENCES Category(CategoryID)
);

CREATE TABLE Region (
    RegionID INT PRIMARY KEY,
    RegionName VARCHAR(100) NOT NULL
);

CREATE TABLE Country (
    CountryID INT PRIMARY KEY,
    CountryName VARCHAR(100) NOT NULL,
    RegionID INT,
    FOREIGN KEY (RegionID) REFERENCES Region(RegionID)
);

CREATE TABLE Sales (
    SaleID INT PRIMARY KEY,
    SaleDate DATE NOT NULL,
    ProductID INT,
    RegionID INT,
    FOREIGN KEY (ProductID) REFERENCES Product(ProductID),
    FOREIGN KEY (RegionID) REFERENCES Region(RegionID)
); 
-- Fine creazione tabelle 

-- Implementazione delle Tabelle
INSERT INTO Category (CategoryID, CategoryName) VALUES
(1, 'Bikes'), (2, 'Clothing'), (3, 'Toys');


INSERT INTO Product (ProductID, ProductName, CategoryID) VALUES
(101, 'Bikes-100', 1), (102, 'Bikes-200', 1),
(201, 'Bike Glove M', 2), (202, 'Bike Glove L', 2),
(301, 'Toy Car', 3), (302, 'Action Figure', 3);


INSERT INTO Region (RegionID, RegionName) VALUES
(10, 'WestEurope'), (20, 'SouthEurope'), (30, 'NorthAmerica');

INSERT INTO Country (CountryID, CountryName, RegionID) VALUES
(100, 'France', 10), (101, 'Germany', 10),
(200, 'Italy', 20), (201, 'Greece', 20),
(300, 'USA', 30), (301, 'Canada', 30);

INSERT INTO Sales (SaleID, SaleDate, ProductID, RegionID, Quantity, Amount) VALUES
(1000, '2023-01-10', 101, 10, 5, 100.00), 
(1001, '2023-02-15', 201, 20, 3, 75.00),
(1002, '2023-03-20', 301, 30, 10, 200.00), 
(1003, '2023-04-25', 202, 10, 2, 50.00),
(1004, '2023-05-30', 302, 20, 7, 150.00);
 -- Fine implementazione tabelle 
 
 
 -- QUERY
 
-- 1) Verificare che i campi definiti come PK siano univoci. 
-- In altre parole, scrivi una query per determinare l’univocità dei valori 
-- di ciascuna PK (una query per tabella implementata). 
SELECT CategoryID, COUNT(*) AS DuplicateCount
FROM Category
GROUP BY CategoryID
HAVING COUNT(*) > 1;

SELECT ProductID, COUNT(*) AS DuplicateCount
FROM Product
GROUP BY ProductID
HAVING COUNT(*) > 1;

SELECT SaleID, COUNT(*) AS DuplicateCount
FROM Sales
GROUP BY SaleID
HAVING COUNT(*) > 1;

-- FINE PRIMO PUNTO

-- 2) 	Esporre l’elenco delle transazioni indicando nel result set il codice documento,
-- la data, il nome del prodotto, la categoria del prodotto,
--  il nome dello stato, il nome della regione di vendita e un campo booleano valorizzato in base alla condizione
-- che siano passati più di 180 giorni dalla data vendita o meno (>180 -> True, <= 180 -> False) 

SELECT 
    s.SaleID AS CodiceDocumento,
    s.SaleDate AS Data,
    p.ProductName AS NomeProdotto,
    c.CategoryName AS CategoriaProdotto,
    cn.CountryName AS NomeStato,
    r.RegionName AS NomeRegioneVendita,
    CASE 
        WHEN DATEDIFF(CURRENT_DATE, s.SaleDate) > 180 THEN TRUE 
        ELSE FALSE 
    END AS Oltre180Giorni
FROM 
    Sales s
JOIN 
    Product p ON s.ProductID = p.ProductID
JOIN 
    Category c ON p.CategoryID = c.CategoryID
JOIN 
    Region r ON s.RegionID = r.RegionID
JOIN 
    Country cn ON r.RegionID = cn.RegionID;
    
    -- FINE SECONDO PUNTO

-- 3) Esporre l’elenco dei prodotti che hanno venduto, in totale, una quantità maggiore della media delle vendite realizzate nell’ultimo anno censito. (ogni valore della condizione deve risultare da una query e non deve essere inserito a mano). Nel result set
-- devono comparire solo il codice prodotto e il totale venduto. 

WITH TotalSales AS (
    SELECT 
        ProductID,
        SUM(Quantity) AS TotaleVenduto
    FROM 
        Sales
    WHERE 
        YEAR(SaleDate) = (SELECT MAX(YEAR(SaleDate)) FROM Sales)
    GROUP BY 
        ProductID
),
AverageSales AS (
    SELECT 
        AVG(TotaleVenduto) AS MediaVendite
    FROM 
        TotalSales
) 
SELECT 
    t.ProductID,
    t.TotaleVenduto 
FROM 
    TotalSales t 
JOIN 
    AverageSales a 
ON 
    t.TotaleVenduto > a.MediaVendite;
    
    -- FINE TERZO PUNTO 
    
    
    -- 4)	Esporre l’elenco dei soli prodotti venduti 
    -- e per ognuno di questi il fatturato totale per anno
    
SELECT 
    p.ProductID,
    p.ProductName,
    YEAR(s.SaleDate) AS Anno,
    SUM(s.Quantity * p.Price) AS FatturatoTotale
FROM 
    Sales s
JOIN 
    Product p ON s.ProductID = p.ProductID
GROUP BY 
    p.ProductID, p.ProductName, YEAR(s.SaleDate);

ALTER TABLE Product ADD COLUMN Price DECIMAL(10, 2);

UPDATE Product
SET Price = CASE 
    WHEN ProductID = 101 THEN 50.00
    WHEN ProductID = 102 THEN  50.00
    WHEN ProductID = 201 THEN 75.00
    WHEN ProductID = 202 THEN 45.00
    WHEN ProductID = 301 THEN 100.00
    WHEN ProductID = 302 THEN 150.00
    ELSE Price -- mantiene il prezzo attuale se non corrisponde a nessun ID
END
WHERE ProductID IN (101,102,  201, 202, 301, 302);

-- FINE QUARTO PUNTO

-- 5)	Esporre il fatturato totale per stato per anno. 
-- Ordina il risultato per data e per fatturato decrescente. 

SELECT 
    cn.CountryName AS Stato,
    YEAR(s.SaleDate) AS Anno,
    SUM(s.Quantity * p.Price) AS FatturatoTotale
FROM 
    Sales s
JOIN 
    Product p ON s.ProductID = p.ProductID
JOIN 
    Region r ON s.RegionID = r.RegionID
JOIN 
    Country cn ON r.RegionID = cn.RegionID
GROUP BY 
    cn.CountryName, YEAR(s.SaleDate)
ORDER BY 
    Anno, FatturatoTotale DESC;
    
    -- FINE QUINTO PUNTO 
    
   -- 6)	Rispondere alla seguente domanda:
   -- qual è la categoria di articoli maggiormente richiesta dal mercato? 
   
    SELECT 
    c.CategoryName,
    SUM(s.Quantity) AS QuantitaTotaleVenduta
FROM 
    Sales s
JOIN 
    Product p ON s.ProductID = p.ProductID
JOIN 
    Category c ON p.CategoryID = c.CategoryID
GROUP BY 
    c.CategoryName
ORDER BY 
    QuantitaTotaleVenduta DESC
LIMIT 1;

-- FINE SESTO PUNTO 

-- 7)Rispondere alla seguente domanda: quali
 -- sono i prodotti invenduti? Proponi due approcci risolutivi differenti. 

SELECT 
    p.ProductID,
    p.ProductName
FROM 
    Product p
LEFT JOIN 
    Sales s ON p.ProductID = s.ProductID
WHERE 
    s.ProductID IS NULL;
    
    -- FINE SETTIMO PUNTO
    
    
  --  8)	Creare una vista sui prodotti in modo tale da esporre una “versione denormalizzata” 
  -- delle informazioni utili (codice prodotto, nome prodotto, nome categoria)
  
  
CREATE VIEW ViewProductInfo AS
SELECT 
    p.ProductID,
    p.ProductName,
    c.CategoryName
FROM 
    Product p
JOIN 
    Category c ON p.CategoryID = c.CategoryID;
    
    -- FINE OTTAVO PUNTO

-- 9)	Creare una vista per le informazioni geografiche 

CREATE VIEW ViewGeographicInfo AS
SELECT 
    cn.CountryID,
    cn.CountryName,
    r.RegionName
FROM 
    Country cn
JOIN 
    Region r ON cn.RegionID = r.RegionID;


SELECT 
    cn.CountryID,
    cn.CountryName,
    r.RegionName
FROM 
    Country cn
JOIN 
    Region r ON cn.RegionID = r.RegionID;
    
    -- FINE NONO PUNTO 










