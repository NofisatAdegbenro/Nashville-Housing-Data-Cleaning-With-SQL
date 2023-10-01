/*

Cleaning Data in SQL Queries

*/


SELECT *
FROM NashvilleHousing

--Standardized Date Format

SELECT SaleDateConverted, CONVERT (Date,SaleDate)
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)

--Populate Property Address Data

SELECT *
FROM NashvilleHousing
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID

SELECT A.ParcelID, A.PropertyAddress, B.ParcelID, B.PropertyAddress, ISNULL(A.PropertyAddress,B.PropertyAddress)
FROM NashvilleHousing AS A
JOIN NashvilleHousing AS B
    ON  A.ParcelID = B.ParcelID
	AND A.[UniqueID ] <> B.[UniqueID ]
WHERE A.PropertyAddress IS NULL

Update A
SET PropertyAddress = ISNULL(A.PropertyAddress,B.PropertyAddress)
From NashvilleHousing A
JOIN NashvilleHousing B
	on A.ParcelID = B.ParcelID
	AND A.[UniqueID ] <> B.[UniqueID ]
Where A.PropertyAddress is null

--Breaking out Address into individual Column (Address, City, State)

SELECT PropertyAddress
FROM NashvilleHousing

SELECT 
SUBSTRING (PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1) AS Address,
SUBSTRING (PropertyAddress, CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress)) AS Address
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )


ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))

SELECT *
FROM NashvilleHousing

SELECT OwnerAddress
FROM NashvilleHousing

Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From NashvilleHousing



ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)

ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)



Select *
From NashvilleHousing

--Change Y and N to Yes and No in "Sold as Vacant" field

SELECT  DISTINCT SoldAsVacant
FROM NashvilleHousing

SELECT  DISTINCT (SoldAsVacant), COUNT (SoldAsVacant)
FROM NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
       WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
FROM NashvilleHousing


Update NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END

-- Remove Duplicates

WITH RowNumCTE AS (
SELECT *,
    ROW_NUMBER () OVER 
	(PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference 
	ORDER BY UniqueID) AS Row_num
FROM NashvilleHousing)
SELECT *
FROM RowNumCTE
WHERE Row_num > 1
ORDER BY PropertyAddress

--Delete
WITH RowNumCTE AS (
SELECT *,
    ROW_NUMBER () OVER 
	(PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference 
	ORDER BY UniqueID) AS Row_num
FROM NashvilleHousing)
DELETE
FROM RowNumCTE
WHERE Row_num > 1



-- Delete Unused Columns

SELECT *
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate
