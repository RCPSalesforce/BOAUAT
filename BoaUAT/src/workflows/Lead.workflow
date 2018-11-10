<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Update_Visit_Field</fullName>
        <field>Number_of_Times_Lead_Visited__c</field>
        <name>Update Visit Field</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>capture_response_time</fullName>
        <field>Response_time__c</field>
        <formula>FLOOR((NOW()-CreatedDate)*1440)</formula>
        <name>capture response time</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>EmailGaurav</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Lead.Email</field>
            <operation>contains</operation>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>When lead status is contacted</fullName>
        <actions>
            <name>capture_response_time</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Lead.Status</field>
            <operation>equals</operation>
            <value>Marketing qualification</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
