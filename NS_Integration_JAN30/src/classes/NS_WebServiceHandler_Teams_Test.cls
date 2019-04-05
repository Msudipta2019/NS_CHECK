/**@author:  Accenture
* @Created Date: 2019-01-30
* @version:  1.0
* @description: This test class is to test the functionality for class: NS_WebServiceHandler_Teams
*/ 
@isTest (SeeallData=false)
private  without sharing class NS_WebServiceHandler_Teams_Test
{
    
    
    /* Test method for checking invokeCarRequestService responce*/
    @isTest static void testinvokeCarRequestService() {        
       /* Profile sysprof = UserTestFactory.createProfile(NS_StaticVariablesUtility.SystemAdministratorProfile);
        User admin = UserTestFactory.createUser(14,sysprof.Id);
        System.runAs( admin ){*/
        String datetest='';
        Date myDate = Date.today();
		Date weekStartSunday = myDate.toStartofWeek();
        Date weekStart=weekStartSunday.addDays(1);
        String weekDate=myDate.month()+'/'+myDate.day()+'/'+myDate.year();
        String startWeekDate=weekStart.month()+'/'+weekStart.day()+'/'+weekStart.year();  
        
        
        System.Test.setMock(HttpCalloutMock.class, new NscorpWSCalloutRequestHandler_Mock());
        NS_WebServiceHandler_Teams.invokeCarRequestService('M06','09665','NS',startWeekDate,weekStart);         
        if(NS_WebServiceHandler_Teams.invokeCarRequestService('M06','09665','NS',startWeekDate,weekStart).ContainsKey('currentWeek'))
        {
            
            list<NS_WebServiceHandler_Teams.CarRequestWrapper> resultlist= new  list<NS_WebServiceHandler_Teams.CarRequestWrapper>();
            resultlist=NS_WebServiceHandler_Teams.invokeCarRequestService('M06','09665','NS',startWeekDate,weekStart).get('currentWeek');
            for(NS_WebServiceHandler_Teams.CarRequestWrapper a:resultlist){
                datetest= a.startWeekDate;
            }
        }
        
                
        system.assertEquals( startWeekDate, datetest);
        
    }
 
}