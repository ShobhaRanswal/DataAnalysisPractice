
/*
Cleaning data in SQL queries 
*/

select *
from NashvilleHousing
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--Standardized date format
select SaleDateConverted, CONVERT(Date,SaleDate)
from NashvilleHousing


update NashvilleHousing 
set SaleDate =  CONVERT(Date,SaleDate)

alter table NashvilleHousing
add SaleDateConverted Date;

update NashvilleHousing 
set SaleDateConverted =  CONVERT(Date,SaleDate);


-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--populate property address data 
-- for those parcelId that doesn't have the address adding it 

select *
from NashvilleHousing
--where PropertyAddress is null
order by ParcelID;

select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,ISNULL(a.PropertyAddress,b.PropertyAddress)
from NashvilleHousing a
join NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null;


update a
set  PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from NashvilleHousing a
join NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null;

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--breaking out Adress into Individual  columns (Address ,City,State)
select PropertyAddress
from NashvilleHousing

select 
substring(PropertyAddress,1,CHARINDEX(',',PropertyAddress) -1) as Address
,SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) as Address
from NashvilleHousing 


Alter table NashvilleHousing
add PropertySplitAddress nvarchar(255);

update NashvilleHousing
set PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

Alter table NashvilleHousing
add PropertySplitCity nvarchar(255);

update NashvilleHousing
set PropertySplitCity =SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))


select 
PARSENAME(REPLACE(OwnerAddress,',','.'),3) as address,
PARSENAME(REPLACE(OwnerAddress,',','.'),2) as state,
PARSENAME(REPLACE(OwnerAddress,',','.'),1) as city
from NashvilleHousing


alter table NashvilleHousing
add OwnerSplitAddress nvarchar(255);

update NashvilleHousing 
set OwnerSplitAddress =PARSENAME(REPLACE(OwnerAddress,',','.'),3)

alter table NashvilleHousing
add OwnerSplitCity nvarchar(255);

update NashvilleHousing 
set OwnerSplitCity =PARSENAME(REPLACE(OwnerAddress,',','.'),2) 


alter table NashvilleHousing
add OwnerSplitState nvarchar(255);

update NashvilleHousing 
set OwnerSplitState =PARSENAME(REPLACE(OwnerAddress,',','.'),1) 

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--Change Y and N to Yes and No in "SoldAsVacant' field

select Distinct (SoldAsVacant),Count(SoldAsvacant)
from NashvilleHousing
Group by SoldAsVacant
order by 2

select SoldAsVacant
, CASE 
WHEN SoldAsVacant ='Y' THEN 'Yes'
When SoldAsVacant ='N' THEN 'No'
ELSE SoldAsVacant
END
from NashvilleHousing
order by 1


update NashvilleHousing 
set  SoldAsVacant  = CASE 
WHEN SoldAsVacant ='Y' THEN 'Yes'
When SoldAsVacant ='N' THEN 'No'
ELSE SoldAsVacant
END
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--Remove Duplicates

--WITH RowNumCTE AS(
--Select *,
--ROW_NUMBER()OVER(
--PARTITION BY ParcelID,PropertyAddress,SalePrice,SaleDate,LegalReference
--order by UniqueID  
--) row_num
--from NashvilleHousing
----order by ParcelID
--)
--select * from RowNumCTE

WITH RowNumCTE AS(
Select *,
ROW_NUMBER()OVER(
PARTITION BY ParcelID,PropertyAddress,SalePrice,SaleDate,LegalReference
order by UniqueID  
) row_num
from NashvilleHousing
--order by ParcelID
)
DELETE 
from RowNumCTE
where row_num > 1


-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--Delete Unused Columns

select *
from NashvilleHousing

alter table NashvilleHousing
Drop Column OwnerAddress,TaxDistrict,PropertyAddress


alter table NashvilleHousing
Drop Column SaleDate