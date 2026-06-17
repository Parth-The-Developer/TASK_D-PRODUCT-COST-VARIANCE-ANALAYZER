 use AdventureWorks2022;
go


  
 

if not exists(SELECT * FROM sys.schemas WHERE name = 'RetailAnalytics')
begin
 exec('create schema RetailAnalytics');
 end;
 go




create function RetailAnalytics.ufn_calculateCostVariance (
@ListPrice money,
@StandardCost money
)

returns money

as 

begin

if @ListPrice is null or @StandardCost is null
return null;

return @ListPrice - @StandardCost;
end;
go




 





create procedure RetailAnalytics.usp_AnalyzeProductCostVariance
 @ProcessedCount INT OUTPUT
as 
begin
begin try
select p.ProductID,
       p.name as ProductName,
       p.StandardCost,
       p.ListPrice,

       RetailAnalytics.ufn_calculateCostVariance(p.ListPrice, p.StandardCost) AS CostVariance,

       case 
       when  p.ListPrice is null or p.StandardCost = 0
       or  p.StandardCost is null or p.StandardCost = 0
             then 'unknown'
        when(p.ListPrice - p.StandardCost)>500
             then 'Large Margin'
        when (p.ListPrice - p.StandardCost) between 100 and 500
              then 'Normal Margin'
        else'low Margin'
        end as MarginClassification,


        case 
        when  p.ListPrice is null or p.StandardCost = 0
       or  p.StandardCost is null or p.StandardCost = 0
            then 'error'
            else 'Success'
            end as ProcessStatus,

       case 
    when (p.ListPrice is null or p.ListPrice = 0) 
         and (p.StandardCost is null or p.StandardCost = 0)
        then 'Rejected: Both ListPrice and StandardCost are null or zero'
    when p.ListPrice is null or p.ListPrice = 0 
        then 'Rejected: ListPrice is null or zero'
    when p.StandardCost is null or p.StandardCost = 0 
        then 'Rejected: StandardCost is null or zero'
    else 'Processed successfully'
end as ProcessingMessage

        from Production.Product p
        order by p.ProductID;

        end try

        begin catch
        select
        null as ProductID,
        'Error'as ProductName,
        null as StandardCost,
        null as ListPrice,
        null as CostVariance,
        'System Error' as MarginClassification,
        'Error'as ProcessingSatus,
        ERROR_MESSAGE() as ProcessingMessage;

        end catch
        end;
        go

        exec RetailAnalytics.usp_AnalyzeProductCostVariance;
        go



      select  RetailAnalytics.ufn_calculateCostVariance (100,60) as parths_work_done;
          


 

 drop PROCEDURE IF EXISTS usp_Test;
GO

CREATE PROCEDURE usp_Test 
 @Count INT OUTPUT
as
begin
 set @Count = 100;
 end;
 go

 declare @Result int;
 exec usp_Test @count = @Result output;
 print @Result; 
 go


