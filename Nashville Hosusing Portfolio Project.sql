----------CLEANING DATA IN SQL QUERIES-------------
Select *
from PortfolioProject..NashvilleHousing 

--Standardize Date Format
Select SaleDateConverted, CONVERT(Date, SaleDate)
from PortfolioProject..NashvilleHousing 

Update NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)

--Populate Property Address Data
Select PropertyAddress
from PortfolioProject..NashvilleHousing 
where PropertyAddress is null

select *
from PortfolioProject..NashvilleHousing
order by ParcelID

--where Parcle ID is the same, but not the same row 
select a.ParcelID, a.PropertyAddress, b.ParcelID,  b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

--Getting rid of null addresses
Update a
SET a.PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress) 
from PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

--Breaking out address into individual columns (address, city, state)
select PropertyAddress
from PortfolioProject..NashvilleHousing
--order by ParcelID

--using a substring and character index to search for a specific value and then stopping 
Select SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address
from PortfolioProject..NashvilleHousing

--Creating new columns

ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))



select OwnerAddress
from PortfolioProject..NashvilleHousing
-- USING PARSENAME 
Select 
PARSENAME(REPLACE(OwnerAddress,',', '.'), 3)
, PARSENAME(REPLACE(OwnerAddress,',', '.'), 2)
,PARSENAME(REPLACE(OwnerAddress,',', '.'), 1)
from PortfolioProject..NashvilleHousing

--ADDING UPDATES TO DATA
ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',', '.'), 3)

ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',', '.'), 2)

ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',', '.'), 1)


--Change Y and N to Yes and No
Select Distinct(SoldAsVacant), count(SoldAsVacant)
from PortfolioProject..NashvilleHousing 
group by SoldAsVacant
order by 2

select SoldAsVacant
, CASE when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	else SoldAsVacant
	end
from PortfolioProject..NashvilleHousing 

Update NashvilleHousing
SET SoldAsVacant = CASE when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	else SoldAsVacant
	end



--Remove Duplicates with CTE function

WITH RowNumCTE AS(
select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY
					UniqueID
					) row_num

from PortfolioProject..NashvilleHousing
--order by ParcelID
)
Delete
from RowNumCTE
Where row_num > 1 

select * 
from PortfolioProject..NashvilleHousing

ALTER TABLE PortfolioProject..NashvilleHousing
DROP column OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE PortfolioProject..NashvilleHousing
DROP column SaleDate