--Cleaning data in SQL queries

SELECT * 
FROM PortfolioProject..NashVilleHousing

-- Standardize date format

SELECT SaleDate, CONVERT(Date,SaleDate) 
FROM PortfolioProject..NashVilleHousing

UPDATE NashVilleHousing
SET SaleDate= CONVERT(Date,SaleDate)

/*Update SaleDate Convert did not worked so I added another table as SaleDateConverted and inserted the date from sale date and it worked*/

ALTER TABLE NASHVILLEHOUSING
ADD SaleDateConverted Date;

UPDATE NashVilleHousing
SET SaleDateConverted= CONVERT(Date,SaleDate)

SELECT SaleDateConverted, CONVERT(Date,SaleDate) 
FROM PortfolioProject..NashVilleHousing

--Populate Property Address Data

SELECT PropertyAddress
FROM PortfolioProject..NashVilleHousing
WHERE PropertyAddress IS NULL

/*checked and there are some null values even the other data is alright so we need to populate the Property Address*/

SELECT *
FROM PortfolioProject..NashVilleHousing
WHERE PropertyAddress IS NULL


SELECT *
FROM PortfolioProject..NashVilleHousing
ORDER BY ParcelID

/*Wandered through some data values and noticed where parcel ID is same Address is same too, so we are going to populate the data by using JOIN on same table*/
--ISNULL is basically used to check if it is null and will populate using dataset or column name

SELECT A.ParcelID, A.PropertyAddress, B.ParcelID, B.PropertyAddress, ISNULL(A.PropertyAddress, B.PropertyAddress)
FROM PortfolioProject..NashVilleHousing A
JOIN PortfolioProject..NashVilleHousing B
ON A.ParcelID= B.ParcelID
AND A.[UniqueID ]<> B.[UniqueID ]
WHERE A.PropertyAddress IS NULL

/*Successfully updated the null columns with the right data using update query as below*/

UPDATE A
SET PropertyAddress = ISNULL(A.PropertyAddress, B.PropertyAddress)
FROM PortfolioProject..NashVilleHousing A
JOIN PortfolioProject..NashVilleHousing B
ON A.ParcelID= B.ParcelID
AND A.[UniqueID ]<> B.[UniqueID ]
WHERE A.PropertyAddress IS NULL


-- Breaking out Address into Individual columns (Address, City, State)

SELECT *
FROM PortfolioProject..NashVilleHousing

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress)) AS State
FROM PortfolioProject..NashVilleHousing


ALTER TABLE NashvilleHousing
ADD PropertySplitAddress Nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )


ALTER TABLE NashvilleHousing
ADD PropertySplitCity Nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))

------------------------------------------------

SELECT OwnerAddress
FROM PortfolioProject.dbo.NashvilleHousing

SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
FROM PortfolioProject.dbo.NashvilleHousing


ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE NashvilleHousing
ADD OwnerSplitCity Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)



ALTER TABLE NashvilleHousing
ADD OwnerSplitState Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)


SELECT *
FROM PortfolioProject.dbo.NashvilleHousing


-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject.dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2


SELECT SoldAsVacant
, CASE
	WHEN SoldAsVacant='Y' THEN 'Yes'
	WHEN SoldAsVacant='N' THEN 'No'
	ELSE SoldAsVacant
	END
FROM PortfolioProject.dbo.NashvilleHousing


UPDATE NashVilleHousing
SET SoldAsVacant = CASE
	WHEN SoldAsVacant='Y' THEN 'Yes'
	WHEN SoldAsVacant='N' THEN 'No'
	ELSE SoldAsVacant
	END


-- Remove Duplicates (Tip : Don't delete or remove duplicates from orignal if not necessary)

WITH ROWNUMCTE AS (
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY PARCELID,
					PROPERTYADDRESS,
					SALEPRICE,
					SALEDATE,
					LEGALREFERENCE
					ORDER BY 
						UNIQUEID
						) ROW_NUM
						
FROM PortfolioProject..NashVilleHousing
)
SELECT *   --WRITE DELETE INSTEAD OF SELECT AND BY THIS WAY DUPLICATE DATA IS REMOVED
FROM ROWNUMCTE
WHERE ROW_NUM > 1
ORDER BY PropertyAddress


-- Delete Unused Columns

Select *
From PortfolioProject.dbo.NashvilleHousing


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate