Select *
From ProjectDatatCleaning..HousingData

Select SaleDate, Convert(Date,SaleDate)
From ProjectDatatCleaning..HousingData

--convert date row

update HousingData
set SaleDate = Convert(Date,SaleDate)


Alter Table HousingData
Add SaleDateConverted Date;

update HousingData
set  SaleDateConverted = Convert(Date,SaleDate)

--Select SaleDateConverted, Convert(Date,SaleDate)
--From ProjectDatatCleaning..HousingData

--Select *
--From ProjectDatatCleaning..HousingData

--Address
Select PropertyAddress
From ProjectDatatCleaning..HousingData

--if address is showing uf as null

Select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From ProjectDatatCleaning..HousingData a
join ProjectDatatCleaning..HousingData b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

Update a
set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From ProjectDatatCleaning..HousingData a
join ProjectDatatCleaning..HousingData b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null



-- breaking Address into Individual

Select PropertyAddress
From ProjectDatatCleaning..HousingData

--Select 
--SUBSTRING(PropertyAddress, 1 , CHARINDEX(',',PropertyAddress)-1) as Address
--From ProjectDatatCleaning..HousingData

--Select 
--SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress) ) as Address
--From ProjectDatatCleaning..HousingData

Select 
SUBSTRING(PropertyAddress, 1 , CHARINDEX(',',PropertyAddress)-1) as Address ,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress) ) as Address
From ProjectDatatCleaning..HousingData

--we can't seperate onecolumn  into two

Alter Table HousingData
Add PropertAddressBreak Nvarchar(255);

update HousingData
set PropertAddressBreak = SUBSTRING(PropertyAddress, 1 , CHARINDEX(',',PropertyAddress)-1)


Alter Table HousingData
Add PropertyCityBreak Nvarchar(255) ;

update HousingData
set PropertyCityBreak = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress) )



--owner Address

Select OwnerAddress
From ProjectDatatCleaning..HousingData

-- can be done by substring but below one is easier

Select 
PARSENAME(REPLACE(OwnerAddress,',','.'),3) as OwnerAddressBreak,
PARSENAME(REPLACE(OwnerAddress,',','.'),2) as OwnerCityBreak, 
PARSENAME(REPLACE(OwnerAddress,',','.'),1) as OwnerStateBreak
From ProjectDatatCleaning..HousingData

Alter Table HousingData
Add 
OwnerAddressBreak Nvarchar(255),
OwnerCityBreak Nvarchar(255),
OwnerStateBreak Nvarchar(255)
;

UPDATE HousingData
set 
OwnerAddressBreak = PARSENAME(REPLACE(OwnerAddress,',','.'),3),
OwnerCityBreak = PARSENAME(REPLACE(OwnerAddress,',','.'),2),
OwnerStateBreak = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

--- changing y and n to Yes and No
Select Distinct(SoldAsVacant),Count(SoldAsVacant)
From ProjectDatatCleaning..HousingData
Group by SoldAsVacant
order by 2

--Wrong Method
update HousingData
--set set SoldAsVAcant = replace(SoldAsVacant,'Y','Yes')
set SoldAsVacant = replace(SoldAsVacant,'Yeses','Yes')

UPDATE HousingData
--set set SoldAsVAcant = replace(SoldAsVacant,'N','No')
set SoldAsVacant = replace(SoldAsVacant,'Noo','No')

--replacing Y and N

--using case

Select SoldAsVacant,
CASE when SoldAsVacant = 'Y' Then 'Yes'
	 when SoldAsVacant = 'N' Then 'No'
	 Else  SoldAsVacant
	 End
From ProjectDatatCleaning..HousingData

UPDATE HousingData
set SoldAsVacant =CASE when SoldAsVacant = 'Y' Then 'Yes'
	 when SoldAsVacant = 'N' Then 'No'
	 Else  SoldAsVacant
	 End

---Remove Duplicate
--using CTE

WITH RowNumCTE AS
(
Select *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				order by UniqueID) row_num
From ProjectDatatCleaning..HousingData
--order by ParcelID
)

 Select *
 From RowNumCTE
 where row_num > 1

 WITH RowNumCTE AS
(
Select *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				order by UniqueID) row_num
From ProjectDatatCleaning..HousingData
--order by ParcelID
)

 Delete
 From RowNumCTE
 where row_num > 1
 

 --Del unused columns
Select *
From ProjectDatatCleaning..HousingData

Alter Table HousingData
Drop Column OwnerAddress,PropertyAddress,TaxDistrict,SaleDate