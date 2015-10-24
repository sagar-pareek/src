public without sharing class TerritoryDataAccess 
{
    public static final String TERRITORY_COUNTRY = 'Countries';

    public static final String TERRITORY_REGION = 'Regions';

    /**
     * @var leadRegionCache Cache Region territory by country code.
     */
    private static Map <String, Territory2> leadRegionCache = new Map <String, Territory2> ();
    
    /**
     * @var userRegionCache Cache Region territory by user Id.
     */
    private static Map <Id, Territory2> userRegionCache = new Map <Id, Territory2> ();
    
    /**
     * @var userTerritoryCache Cache user territory pivot by user Id.
     */
    private static Map <Id, List<UserTerritory2Association>> userTerritoryCache = new Map <Id, List<UserTerritory2Association>> ();
    
    /**
     * Get the region of a lead.
     * 
     * @param lead
     * @return Territory2
     * @author Mohammad Gufran <mohammad.gufran@kayako.com>
     */
    public static Territory2 GetLeadRegion(Lead lead)
    {
        if(leadRegionCache.containsKey(lead.CountryCode)) return leadRegionCache.get(lead.CountryCode);
        
        try
        {
            Territory2 childTerritory = [SELECT ParentTerritory2.id, ParentTerritory2.Name, ParentTerritory2.DeveloperName FROM Territory2 WHERE DeveloperName = :lead.CountryCode LIMIT 1];

            Territory2 region = new Territory2(Id = childTerritory.ParentTerritory2.id, Name = childTerritory.ParentTerritory2.Name, DeveloperName = childTerritory.ParentTerritory2.DeveloperName);
            
            leadRegionCache.put(lead.CountryCode, region);
            
            return region;
        }
        catch(QueryException nullResultException)
        {
            throw new UnderflowException('No region exists by country code ' + lead.CountryCode);
        }
    }

    /**
     * Get the User and Territory association.
     *
     * @param userId Id
     * @param territoryId Id
     * @return UserTerritory2Association
     * @author Mohammad Gufran <mohammad.gufran@kayako.com>
     */
    public static UserTerritory2Association GetUserWithTerritory(Id userId, Id territoryId)
    {
        try
        {
            UserTerritory2Association association = [SELECT RoleInTerritory2, Territory2.Id, User.Id from UserTerritory2Association WHERE (User.Id = :userId and Territory2.Id = :territoryId) Limit 1];

            return association;
        }
        catch(QueryException associationDoesNotExist)
        {
            throw new UnderflowException('No association found between User and Territory');
        }
    }
    
    /**
     * Get region by userId.
     * 
     * @param userId
     * @return Territory2
     * @author Mohammad Gufran <mohammad.gufran@kayako.com>
     */
    public static List <Territory2> GetUsersRegion(Id userId)
    {
        try
        {
            Set <Id> pivotIds = new Set <Id> ();
            List <UserTerritory2Association> pivots = [SELECT Territory2.Id
                                                        from UserTerritory2Association
                                                        WHERE User.Id = :userId];

            for(UserTerritory2Association territoryPivot : pivots)
            {
                pivotIds.add(territoryPivot.Territory2.Id);
            }

           return [SELECT Id, Name, DeveloperName FROM Territory2 WHERE Id IN :pivotIds];
        }
        catch(QueryException nullResultException)
        {
            throw new UnderflowException('User is not associated with any Territory');
        }
    }
    
    /**
     * Get User and Territory pivots by territory.
     * 
     * @param territory.
     * @return List<UserTerritory2Association>
     * @author Mohammad Gufran <mohammad.gufran@kayako.com>
     */
    public static List<UserTerritory2Association> GetUserTerritoryPivots(Territory2 territory)
    {
        if(userTerritoryCache.containsKey(territory.Id)) return userTerritoryCache.get(territory.Id);
        
        try
        {
            List<UserTerritory2Association> territoryPivots = [SELECT User.Id, User.KA_Weightage__c, User.KA_LeadCounter__c, RoleInTerritory2, Territory2.Id
                FROM UserTerritory2Association
                WHERE (Territory2.Id = :territory.id and User.KA_Weightage__c > 0 and User.IsActive = true)
                ORDER BY User.KA_Weightage__c DESC];

            userTerritoryCache.put(territory.Id, territoryPivots);
            
            return territoryPivots;
        }
        catch(QueryException nullResultException)
        {
            throw new UnderflowException('No association records exists for Territory ' + territory.Name + ' with Code ' + territory.DeveloperName);
        }
    }

    /**
     * Get User and Territory pivots by territory.
     * 
     * @param user
     * @param territory
     * @return UserTerritory2Association
     * @author Mohammad Gufran <mohammad.gufran@kayako.com>
     */
    public static UserTerritory2Association GetTerritoryPivotForUser(User user, Territory2 territory)
    {
        try
        {
            UserTerritory2Association pivot = [SELECT User.Id, User.KA_Weightage__c, User.KA_LeadCounter__c, RoleInTerritory2, Territory2.Id
            	FROM UserTerritory2Association
	            WHERE (User.Id = :user.Id and Territory2.Id = :territory.id and User.IsActive = true)
	            ORDER BY User.KA_Weightage__c DESC LIMIT 1];

			if((! RoleName.SeniorRoles().contains(pivot.RoleInTerritory2)) && pivot.User.KA_Weightage__c < 1)
			{
				throw new ErrorException('You have an assignment weightage of 0, weightage of 1 or more is required.');
			}

            return pivot;
        }
        catch(QueryException pivotNotFound)
        {
            throw new UnderflowException('User does not exist in region ' + territory.Name);
        }
    }

    public static String GetUserRole(User user, Territory2 territory)
    {
        try
        {
            return GetTerritoryPivotForUser(user, territory).RoleInTerritory2;            
        }
        catch(UnderflowException pivotDoesNotExist)
        {
            return '';
        }
    }

    public static Set <Territory2> GetCountriesInRegion(Territory2 region)
    {
        try
        {
            List <Territory2> countries = [SELECT Id, Name, DeveloperName FROM Territory2
                                            WHERE ParentTerritory2.Id = :region.Id];

            return new Set <Territory2> (countries);
        }
        catch(QueryException cannotFetchCountries)
        {
            return new Set <Territory2> ();
        }
    }

    public static Set <Territory2> GetCountriesInRegion(List <Territory2> regions)
    {
        Set <Id> regionIds = new Set <Id> ();

        for(Territory2 region : regions)
        {
            regionIds.add(region.Id);
        }

        try
        {
            List <Territory2> countries = [SELECT Id, Name, DeveloperName FROM Territory2
                                            WHERE ParentTerritory2.Id IN :regionIds];

            return new Set <Territory2> (countries);
        }
        catch(QueryException cannotFetchcountries)
        {
            return new Set <Territory2> ();
        }
    }

    public static List <Territory2> GetAllCountries()
    {
        return [SELECT Id, Name, DeveloperName, ParentTerritory2.Id, ParentTerritory2.Name, ParentTerritory2.DeveloperName FROM Territory2 WHERE Territory2Type.DeveloperName = :TERRITORY_COUNTRY];
    }

    public static Territory2 GetCountryById(Id countryId)
    {
        Territory2 country = [SELECT Id, ParentTerritory2.Id, ParentTerritory2.Name, ParentTerritory2.DeveloperName, Name, DeveloperName
                            FROM Territory2 
                            WHERE Id = :countryId LIMIT 1];

        return country;
    }
}