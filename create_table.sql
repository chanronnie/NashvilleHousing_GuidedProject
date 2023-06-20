##########################################################
# This SQL script imports dataset (CSV files) with MySQL
# and creates table.
##########################################################



####   Error Code: 3948   ####
# If "Error Code: 3948" occurs when loading dataset, run the two following lines of codes
SHOW GLOBAL VARIABLES LIKE 'local_infile';
SET GLOBAL local_infile=1;



-- Create a database
CREATE DATABASE IF NOT EXISTS nashville_housing;

-- Create a table
CREATE TABLE IF NOT EXISTS nashville_housing.nashville
(
	UniqueID INT DEFAULT NULL,
	ParcelID VARCHAR(255) DEFAULT NULL, 
	LandUse VARCHAR(255) DEFAULT NULL, 
	PropertyAddress VARCHAR(255) DEFAULT NULL, 
	SaleDate VARCHAR(255) DEFAULT NULL, 
	SalePrice INT DEFAULT NULL, 
	LegalReference VARCHAR(255) DEFAULT NULL, 
	SoldAsVacant VARCHAR(255) DEFAULT NULL, 
	OwnerName VARCHAR(255) DEFAULT NULL, 
	OwnerAddress VARCHAR(255) DEFAULT NULL, 
	Acreage DOUBLE DEFAULT NULL, 
	TaxDistrict VARCHAR(255) DEFAULT NULL, 
	LandValue INT DEFAULT NULL, 
	BuildingValue INT DEFAULT NULL,  
	TotalValue INT DEFAULT NULL,  
	YearBuilt INT DEFAULT NULL,  
	Bedrooms INT DEFAULT NULL,  
	FullBath INT DEFAULT NULL,  
	HalfBath INT DEFAULT NULL
);

-- Populate table with NashvilleHousingData.csv file
load data local infile '/ProgramData/MySQL/MySQL Server 8.0/Uploads/NashvilleHousing/NashvilleHousingData.csv'
into table nashville_housing.nashville
fields terminated by ','
enclosed by '"'
lines terminated by '\n'
ignore 1 lines
(UniqueID, ParcelID, LandUse, @vPropertyAddress, SaleDate, SalePrice, LegalReference, SoldAsVacant, @vOwnerName, @vOwnerAddress, @vAcreage, 
@vTaxDistrict, @vLandValue, @vBuildingValue, @vTotalValue, @vYearBuilt, @vBedrooms, @vFullBath, @vHalfBath)
SET
	-- Keep NULL values when loading dataset
    PropertyAddress = NULLIF(@vPropertyAddress, ''),
	OwnerName = NULLIF(@vOwnerName, ''), 
	OwnerAddress = NULLIF(@vOwnerAddress, ''), 
	Acreage = NULLIF(@vAcreage, ''), 
	TaxDistrict = NULLIF(@vTaxDistrict, ''), 
	LandValue = NULLIF(@vLandValue, ''), 
	BuildingValue = NULLIF(@vBuildingValue, ''),  
	TotalValue = NULLIF(@vTotalValue, ''), 
	YearBuilt = NULLIF(@vYearBuilt, ''), 
	Bedrooms = NULLIF(@vBedrooms, ''), 
	FullBath = NULLIF(@vFullBath, ''), 
	HalfBath = NULLIF(@vHalfBath, '')
;

-- Visualize the table
SELECT * FROM nashville_housing.nashville;
