##########################################################
# This SQL script is for conducting data cleaning.
# Skills: JOINS, CTE, Window Function, UPDATE, ALTER
##########################################################



USE nashville_housing;
SELECT * FROM nashville;


----------------------------------------------------------
-- 1. Standardize Date format on SaleDate column
ALTER TABLE nashville
ADD COLUMN SaleDateConverted DATE AFTER SaleDate;

UPDATE nashville
SET SaleDateConverted = STR_TO_DATE(SaleDate, '%M %d,%Y');


----------------------------------------------------------
-- 2. Handdle Missing Values in PropertyAddress Column
SELECT 
    a.UniqueID,
    a.ParcelID,
    a.PropertyAddress,
    b.UniqueID,
    b.ParcelID,
    b.PropertyAddress,
    IFNULL(a.PropertyAddress, b.PropertyAddress) AS PropertyAddressComplete
FROM nashville a
JOIN nashville b 
ON a.ParcelID = b.ParcelID AND a.UniqueID != b.UniqueID
WHERE a.PropertyAddress IS NULL;
    
-- Fill the NULL values on the PropertyAddress column with Address having the same ParcelID
UPDATE nashville AS a
JOIN nashville AS b ON a.ParcelID = b.ParcelID AND a.UniqueID != b.UniqueID
SET a.PropertyAddress = IFNULL(a.PropertyAddress, b.PropertyAddress)
WHERE a.PropertyAddress IS NULL;


----------------------------------------------------------
-- 3. Split Address Info into Individuals Columns (Address, City, State)
SELECT 
    PropertyAddress,
    SUBSTRING_INDEX(PropertyAddress, ',', 1) AS Address,
    SUBSTRING_INDEX(PropertyAddress, ',', - 1) AS City
FROM nashville;


SELECT 
	OwnerAddress,
	SUBSTRING_INDEX(OwnerAddress, ',', 1) AS Address,
	SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2), ',', -1) AS City, 
	SUBSTRING_INDEX(OwnerAddress, ',', -1) AS State
FROM nashville;


-- Create individual columns to hold Address Data
ALTER TABLE nashville
ADD COLUMN PropertySplitCity VARCHAR(255) AFTER PropertyAddress,
ADD COLUMN PropertySplitAddress VARCHAR(255) AFTER PropertyAddress,
ADD COLUMN OwnerSplitState VARCHAR(255) AFTER OwnerAddress,
ADD COLUMN OwnerSplitCity VARCHAR(255) AFTER OwnerAddress,
ADD COLUMN OwnerSplitAddress VARCHAR(255) AFTER OwnerAddress;

-- Populate the newly created columns with Address Data
UPDATE nashville 
SET 
PropertySplitCity = SUBSTRING_INDEX(PropertyAddress, ',', -1),
PropertySplitAddress = SUBSTRING_INDEX(PropertyAddress, ',', 1),
OwnerSplitState = SUBSTRING_INDEX(OwnerAddress, ',', -1),
OwnerSplitCity = SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2), ',', -1),
OwnerSplitAddress = SUBSTRING_INDEX(OwnerAddress, ',', 1);


----------------------------------------------------------
-- 4. Replace 'Y'/'N' values to 'Yes'/'No' in 'SoldAsVacant' field

-- Unique Values: 'Y', 'N', 'Yes' and 'No'
SELECT DISTINCT SoldAsVacant, COUNT(SoldAsVacant) AS Frequency
FROM nashville
GROUP BY SoldAsVacant 
ORDER BY Frequency ASC;

-- Check our query
SELECT 
    SoldAsVacant,
    CASE 
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
        WHEN SoldAsVacant = 'N' THEN 'No'
        ELSE SoldAsVacant
    END AS SoldAsVacantCorrected
FROM nashville;

-- Standardize the data in the 'SoldAsVacant' field
UPDATE nashville 
SET 
SoldAsVacant = CASE
WHEN SoldAsVacant = 'Y' THEN 'Yes'
WHEN SoldAsVacant = 'N' THEN 'No'
ELSE SoldAsVacant
END;


----------------------------------------------------------
-- 5. Drop Duplicates (Three ways)

# Method no1: Check Duplicates with CTE
WITH RowNumCTE AS
(
SELECT *, ROW_NUMBER() OVER (PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference ORDER BY UniqueID) AS row_num
FROM nashville
ORDER BY ParcelID
)
SELECT * FROM RowNumCTE
WHERE row_num > 1
ORDER BY UniqueID;

-----
# Method no2: Check Duplicates with NESTED SELECT
SELECT * FROM 
(
SELECT *, ROW_NUMBER() OVER (PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference ORDER BY UniqueID) AS row_num
FROM nashville
) nash_table
WHERE row_num > 1
ORDER BY UniqueID
;

-----
# Method no3: Check Duplicates with INNER JOINS
SELECT *
FROM nashville a
JOIN nashville b 
WHERE a.UniqueID < b.UniqueID 
AND a.ParcelID = b.ParcelID
AND a.PropertyAddress = b.PropertyAddress
AND a.SalePrice = b.SalePrice
AND a.SaleDate = b.SaleDate
AND a.LegalReference = b.LegalReference
ORDER BY a.UniqueID;

-----
# Drop Duplicates 
DELETE FROM nashville WHERE UniqueID IN (
SELECT UniqueID FROM 
(
SELECT *, ROW_NUMBER() OVER (PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference ORDER BY UniqueID) AS row_num
FROM nashville
) nash_table
WHERE row_num > 1
ORDER BY UniqueID);


----------------------------------------------------------
-- 6. Remove Unused Columns
ALTER TABLE nashville
DROP COLUMN SaleDate,
DROP COLUMN TaxDistrict,
DROP COLUMN PropertyAddress, 
DROP COLUMN OwnerAddress;

-- 7. Visualize and Save the processed table
SELECT * FROM nashville;
COMMIT;