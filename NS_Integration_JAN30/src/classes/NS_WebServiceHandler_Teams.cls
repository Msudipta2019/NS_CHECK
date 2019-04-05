/*======================================================================================================
* @Class Name : NS_WebServiceHandler_Teams
* @author : Accenture
* @Purpose: This is a Callout Service class to make HTTP callout for Teams
* @created date: 09-01-2018
* @Change Logs:									
----------------------------------------------------------------------------------------------------------
Developer name        Date          Description        
----------------------------------------------------------------------------------------------------------
@Arjun Ghosh          09-01-2019    Request No.   , Phase-II
Methods Created: invokeCarRequestService(),carRequestResponseParser()
Inner class:CarRequestWrapper
----------------------------------------------------------------------------------------------------------
Record next changes here
==========================================================================================================*/

public class NS_WebServiceHandler_Teams {
    /* ================================================
* @Method Name : invokeCarRequestService
* @author id: arjun.c.ghosh@accenture.com
* @Purpose: This method is used to make a callout to get the TEAMS CarRequestSummary data
* @Parameters: String ClassCode,String StationCode,String ServingRoad, String StartWeekDate
* @return: CarRequestWrapper
* @created date: 09-01-2019
================================================*/    
    public Static  Map<String,List<CarRequestWrapper>> invokeCarRequestService(String cCode, String oSCode, String sRoad, String startWeekDate, Date weekStart){        
        String endpoint = NS_IntegrationUtility_Teams.TEAMS_ENDPOINT;
        String Action=NS_IntegrationUtility_Teams.CAR_REQ_SUMMARY_ACTION;
        String body = NS_StaticVariablesUtility.getCarRequestBody(cCode, oSCode, sRoad,startWeekDate);
        String signedBody =NS_IntegrationUtility_Teams.prepareSignedBodyforCarRequestService(body);
        
        String response=NS_IntegrationUtility_Teams.sendRequest(endpoint, NS_StaticVariablesUtility.postmethod, NS_StaticVariablesUtility.contentType,Action, signedBody);
        
        Map<String,List<CarRequestWrapper>> ret=carRequestResponseParser(response,weekStart);
        return ret;
    }
    /* ================================================
* @Method Name : carRequestResponseParser
* @author id: arjun.c.ghosh@accenture.com
* @Purpose: This method is used to parse the xml response from the Action GetCarRequestSummary
* @Parameters: String response, Date End date of the week
* @return: CarRequestWrapper
* @created date: 09-01-2019
================================================*/    
    public Static  Map<String,List<CarRequestWrapper>>  carRequestResponseParser(String response,Date weekStart){     
        List<CarRequestWrapper> rrListforCurrentWeek = new List<CarRequestWrapper>();
        List<CarRequestWrapper> rrListforNextWeek = new List<CarRequestWrapper>();
        Map<String,List<CarRequestWrapper>> mCrList=new Map<String,List<CarRequestWrapper>>();
        Dom.Document docForResponse = new dom.Document();
        docForResponse.load(response);       
        Dom.XmlNode res_envelope = docForResponse.getRootElement();
        Dom.XmlNode bodyElement=res_envelope.getChildElement(NS_StaticVariablesUtility.Body, NS_StaticVariablesUtility.soapNS);
        Dom.XmlNode getCarRequestSummaryResponse =bodyElement.getChildElement(NS_IntegrationUtility_Teams.ELEMENT_CRSRES,NS_StaticVariablesUtility.tem);
        Dom.XmlNode getCarRequestSummaryResult=getCarRequestSummaryResponse.getChildElement(NS_IntegrationUtility_Teams.ELEMENT_CRSR,NS_StaticVariablesUtility.tem);
        Dom.XmlNode carRequestSummaryList=getCarRequestSummaryResult.getChildElement(NS_IntegrationUtility_Teams.ELEMENT_CRSL,NS_IntegrationUtility_Teams.NS_CRSL);
        for(Dom.XmlNode carRequestSummary : carRequestSummaryList.getChildElements()){
            Dom.XmlNode accepted= carRequestSummary.getChildElement(NS_IntegrationUtility_Teams.ACCEPTED, NS_IntegrationUtility_Teams.NS_CRS);  
            Dom.XmlNode customerPattern= carRequestSummary.getChildElement(NS_IntegrationUtility_Teams.C_PATTERN, NS_IntegrationUtility_Teams.NS_CRS);
            Dom.XmlNode fulfilled= carRequestSummary.getChildElement(NS_IntegrationUtility_Teams.F_FILLED, NS_IntegrationUtility_Teams.NS_CRS);
            Dom.XmlNode loadFill= carRequestSummary.getChildElement(NS_IntegrationUtility_Teams.L_FILL, NS_IntegrationUtility_Teams.NS_CRS);
            Dom.XmlNode marketingPriorityRank= carRequestSummary.getChildElement(NS_IntegrationUtility_Teams.MPR, NS_IntegrationUtility_Teams.NS_CRS);
            Dom.XmlNode orderFill= carRequestSummary.getChildElement(NS_IntegrationUtility_Teams.O_FILL, NS_IntegrationUtility_Teams.NS_CRS);
            Dom.XmlNode projected= carRequestSummary.getChildElement(NS_IntegrationUtility_Teams.PROJECTED, NS_IntegrationUtility_Teams.NS_CRS);
            Dom.XmlNode requestFill= carRequestSummary.getChildElement(NS_IntegrationUtility_Teams.R_FILL, NS_IntegrationUtility_Teams.NS_CRS);
            Dom.XmlNode requested= carRequestSummary.getChildElement(NS_IntegrationUtility_Teams.REQUESTED, NS_IntegrationUtility_Teams.NS_CRS);
            Dom.XmlNode startWeekDate= carRequestSummary.getChildElement(NS_IntegrationUtility_Teams.SWD, NS_IntegrationUtility_Teams.NS_CRS);
            Dom.XmlNode surplusShortage= carRequestSummary.getChildElement(NS_IntegrationUtility_Teams.S_SHORT, NS_IntegrationUtility_Teams.NS_CRS);
            Dom.XmlNode weeklyFillTarget= carRequestSummary.getChildElement(NS_IntegrationUtility_Teams.WFT, NS_IntegrationUtility_Teams.NS_CRS);
            CarRequestWrapper cr = new CarRequestWrapper(accepted.getText(),customerPattern.getText(),fulfilled.getText(),
                                                         loadFill.getText(),marketingPriorityRank.getText(),orderFill.getText(),
                                                         projected.getText(),requestFill.getText(),requested.getText(),
                                                         startWeekDate.getText(),surplusShortage.getText(),weeklyFillTarget.getText()); 
            Date dt= date.parse(cr.startWeekDate);            
            if(dt.daysBetween(weekStart)==0){                
                rrListforCurrentWeek.add(cr);                
            }else if(dt.daysBetween(weekStart)==-7){
                rrListforNextWeek.add(cr);                
            }            
            mCrList.put(NS_IntegrationUtility_Teams.cWk, rrListforCurrentWeek);
            mCrList.put(NS_IntegrationUtility_Teams.nWk, rrListforNextWeek); 
        }        
        return mCrList;
    }
    /* ================================================
* @Inner Class Name : CarRequestWrapper
* @author id: arjun.c.ghosh@accenture.com
* @Purpose: Wrapper class for the response
* @created date: 09-01-2019
================================================*/
    public class CarRequestWrapper{
        @AuraEnabled public string accepted;
        @AuraEnabled public string customerPattern;
        @AuraEnabled public string fulfilled;
        @AuraEnabled public string loadFill;
        @AuraEnabled public string marketingPriorityRank;
        @AuraEnabled public string orderFill;
        @AuraEnabled public string projected;
        @AuraEnabled public string requestFill;
        @AuraEnabled public string requested;
        @AuraEnabled public string startWeekDate;
        @AuraEnabled public string surplusShortage;
        @AuraEnabled public string weeklyFillTarget;
        
        public CarRequestWrapper(String accepted, String customerPattern, String fulfilled, String loadFill, String marketingPriorityRank, String orderFill, String projected, 
                                 String requestFill, String requested, String startWeekDate,String surplusShortage, String weeklyFillTarget){
                                     this.accepted=accepted;
                                     this.customerPattern=customerPattern;
                                     this.fulfilled=fulfilled;
                                     this.loadFill=loadFill;
                                     this.marketingPriorityRank=marketingPriorityRank;
                                     this.orderFill=orderFill;
                                     this.projected=projected;
                                     this.requestFill=requestFill;
                                     this.requested=requested;
                                     this.startWeekDate=startWeekDate;
                                     this.surplusShortage=surplusShortage;
                                     this.weeklyFillTarget=weeklyFillTarget;
                                 }
    }
    
}