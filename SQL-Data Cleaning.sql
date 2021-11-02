/*
Cleaning data in SQL Queies
*/

SELECT *
FROM "Portfolio Project".dbo.Nashvillehousing


-- Standarize date format
SELECT SaleDate, CONVERT(Date,SaleDate)
FROM "Portfolio Project".dbo.Nashvillehousing

UPDATE Nashvillehousing
SET SaleDate = CONVERT(Date,SaleDate)

-- The above expression did not work

ALTER TABLE Nashvillehousing
ADD SaleDateConverted DATE;

UPDATE Nashvillehousing
SET SaleDateConverted = CONVERT(Date,SaleDate)

SELECT SaleDateConverted
FROM "Portfolio Project".dbo.Nashvillehousing


-- Populate Property address data

SELECT *
FROM "Portfolio Project".dbo.Nashvillehousing
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID


SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM [Portfolio Project].dbo.Nashvillehousing a
JOIN [Portfolio Project].dbo.Nashvillehousing b
     ON a.ParcelID = b.ParcelID
	 AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM [Portfolio Project].dbo.Nashvillehousing a
JOIN [Portfolio Project].dbo.Nashvillehousing b
     ON a.ParcelID = b.ParcelID
	 AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL


-- Breaking out address into individual columns (Address, City, State)


SELECT PropertyAddress
FROM "Portfolio Project".dbo.Nashvillehousing


SELECT SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) as Address

FROM "Portfolio Project".dbo.Nashvillehousing



ALTER TABLE Nashvillehousing
ADD PropertySplitAddress Nvarchar(255);

UPDATE Nashvillehousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1)



ALTER TABLE Nashvillehousing
ADD PropertySplitCity Nvarchar(255);

UPDATE Nashvillehousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))



SELECT *
FROM "Portfolio Project".dbo.Nashvillehousing



SELECT OwnerAddress
FROM "Portfolio Project".dbo.Nashvillehousing

SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM "Portfolio Project".dbo.Nashvillehousing



ALTER TABLE Nashvillehousing
ADD OwnerSplitAddress Nvarchar(255);

UPDATE Nashvillehousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE Nashvillehousing
ADD OwnerSplitCity Nvarchar(255);

UPDATE Nashvillehousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE Nashvillehousing
ADD OwnerSplitState Nvarchar(255);

UPDATE Nashvillehousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

SELECT *
FROM "Portfolio Project".dbo.Nashvillehousing

-- Change Y and N to Yes and No in "Sold as Vacant" field


SELECT Distinct(SoldAsVacant), COUNT(SoldAsVacant)
FROM "Portfolio Project".dbo.Nashvillehousing
GROUP BY SoldAsVacant
ORDER BY 2




SELECT SoldAsVacant,
 CASE  WHEN SoldAsVacant = 'Y' THEN 'Yes'
       WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
FROM "Portfolio Project".dbo.Nashvillehousing




