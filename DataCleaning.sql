-- Data Cleaning Steps

select * from dbo.Nashville;
---------------------------------------------------------------------------------------------------------------------------
-- SaleDate: DateTime To Date
select SaleDate
from dbo.Nashville;

alter table dbo.Nashville
add SaleDateConverted Date;

update dbo.Nashville
set SaleDateConverted = convert(Date, SaleDate);

---------------------------------------------------------------------------------------------------------------------------
-- PropertyAddress: Eliminate NULL values

select *
from dbo.Nashville
where PropertyAddress is null;

-- Check if same ParcelID, PropertyAddress combo exist (Do a self join)
select n1.ParcelID, n1.PropertyAddress, n2.ParcelID, n2.PropertyAddress, ISNULL(n1.PropertyAddress, n2.PropertyAddress)
from dbo.Nashville as n1
join dbo.Nashville as n2
on n1.ParcelID = n2.ParcelID
and n1.[UniqueID ] <> n2.[UniqueID ]
where n1.PropertyAddress is null;

-- There are ParcelID records for which PropertyAddress exists but is not populated. Update n1 to populate those null records
update n1
set PropertyAddress = ISNULL(n1.PropertyAddress, n2.PropertyAddress)
from dbo.Nashville as n1
join dbo.Nashville as n2
on n1.ParcelID = n2.ParcelID
and n1.[UniqueID ] <> n2.[UniqueID ]
where n1.PropertyAddress is null;

-- PropertyAddress: Separate to Address, City, State
select PropertyAddress
from dbo.Nashville;

-- Using Substring
select
substring(PropertyAddress, 1, charindex(',', PropertyAddress) - 1) as Address,
substring(PropertyAddress, charindex(',', PropertyAddress) + 1, len(PropertyAddress)) as City
from dbo.Nashville;

alter table Nashville
add PropertySplitAddress Varchar(255);
update Nashville
set PropertySplitAddress = substring(PropertyAddress, 1, charindex(',', PropertyAddress) - 1);

alter table Nashville
add PropertySplitCity Varchar(255);
update Nashville
set PropertySplitCity = substring(PropertyAddress, charindex(',', PropertyAddress)+1, len(PropertyAddress));

---------------------------------------------------------------------------------------------------------------------------
-- OwnerAddress: Split to Address, City, State
-- Using Parsename
select
parsename(replace(OwnerAddress, ',', '.'), 3),
parsename(replace(OwnerAddress, ',', '.'), 2),
parsename(replace(OwnerAddress, ',', '.'), 1)
from Nashville;

select * from Nashville;

alter table Nashville
add OwnerSplitAddress Varchar(255);
update Nashville
set OwnerSplitAddress = parsename(replace(OwnerAddress, ',', '.'), 3);

alter table Nashville
add OwnerSplitCity Varchar(255);
update Nashville
set OwnerSplitCity = parsename(replace(OwnerAddress, ',', '.'), 2);

alter table Nashville
add OwnerSplitState Varchar(255);
update Nashville
set OwnerSplitState = parsename(replace(OwnerAddress, ',', '.'), 1);

---------------------------------------------------------------------------------------------------------------------------
-- SoldAsVacant: Clean 'Y', 'N', 'Yes', 'No'
select distinct(SoldAsVacant)
from Nashville;

select distinct(SoldAsVacant), count(SoldAsVacant)
from Nashville
group by SoldAsVacant;

select SoldAsVacant, 
case when SoldAsVacant = 'N' then 'No'
	 when SoldAsVacant = 'Y' then 'Yes'
	 else SoldAsVacant
	 end
from dbo.Nashville;

update Nashville
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
						when SoldAsVacant = 'N' then 'No'
						else SoldAsVacant
						end;

---------------------------------------------------------------------------------------------------------------------------
-- Remove Duplicates
-- Using CTE, Common Table Expression

-- Show rows with duplicate values
with RowNumCTE as(
select *, ROW_NUMBER() OVER( Partition by
	ParcelID,
	PropertyAddress,
	SalePrice,
	SaleDate,
	LegalReference
	order by UniqueID) row_num

from dbo.Nashville
)
select * from RowNumCTE
where row_num > 1
order by PropertyAddress;

-- Delete rows with duplicate values
with RowNumCTE as(
select *, row_number() over( partition by
	ParcelID,
	PropertyAddress,
	SalePrice,
	SaleDate,
	LegalReference
	order by UniqueID) row_num
from dbo.Nashville
)
delete from RowNumCTE
where row_num>1;

---------------------------------------------------------------------------------------------------------------------------
-- Delete Unused Columns
alter table dbo.Nashville
drop column OwnerAddress, TaxDistrict, PropertyAddress;

alter table dbo.Nashville
drop column SaleDate;

---------------------------------------------------------------------------------------------------------------------------