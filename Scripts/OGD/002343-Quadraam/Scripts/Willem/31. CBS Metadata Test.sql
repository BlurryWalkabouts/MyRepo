-- https://stackoverflow.com/questions/15995480/illegal-xml-character-on-sql-insert
-- https://stackoverflow.com/questions/28365316/sql-server-replace-invalid-xml-characters-from-a-varcharmax-field

declare @xml xml
set @xml =
N'<?xml version="1.0" encoding="utf-16"?>
<root>
        <names>
                <name>test</name>
        </names>
        <names>
                <name>test1</name>
        </names>
</root>

'

SELECT
x.value('name[1]', 'varchar(10)') as Name
FROM
@xml.nodes('/root/names') t(x)
GO

declare @xml xml
set @xml =
N'<edmx:Edmx xmlns:edmx="http://schemas.microsoft.com/ado/2007/06/edmx" Version="1.0">
  <edmx:DataServices xmlns:m="http://schemas.microsoft.com/ado/2007/08/dataservices/metadata" m:DataServiceVersion="3.0">
    <Schema xmlns="http://schemas.microsoft.com/ado/2006/04/edm" Namespace="Cbs.OData">
      <EntityType Name="CategoryGroup">
        <Key>
          <PropertyRef Name="ID" />
        </Key>
        <Property Name="ID" Type="Edm.Int32" Nullable="false" />
        <Property Name="DimensionKey" Type="Edm.String" />
        <Property Name="Title" Type="Edm.String" />
        <Property Name="Description" Type="Edm.String" />
        <Property Name="ParentID" Type="Edm.Int32" />
      </EntityType>
    </Schema>
  </edmx:DataServices>
</edmx:Edmx>

'

SELECT
x.query('.')
,x.value('EntityType[1]/Property[1]/@ID', 'varchar(10)') as Name
FROM
@xml.nodes('/edmx:Edmx/edmx:DataServices') t(x)