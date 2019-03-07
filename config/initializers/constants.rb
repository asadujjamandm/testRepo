#NSI_SERVICE_URL = 'http://www.wiptime.com:8009/NSITest/' # SSL disabled
#NSI_SERVICE_URL = 'https://www.wiptime.com:8443/WIPNSI'   # SSL enabled
#NSI_SERVICE_URL = 'http://192.168.88.88:8080/NSIService/'   # SSL enabled
#NSI_SERVICE_URL = 'http://192.168.88.230:8080/NSIService/'   # SSL enabled
#NSI_SERVICE_URL = 'http://www.wiptime.com:8009/NSINidaan/'
NSI_SERVICE_URL = 'http://localhost:8080/NSIService/' 
NSI_DEVICE_SMARTPHONE = 'smartphone'
NSI_QUERY_KEY = 'query'

NSI_SERVICE_ACTIVITYCODE = 'ActivityCode'
NSI_SERVICE_FARMNAME = 'FarmName'
NSI_SERVICE_USERSUB = 'UserSub'
NSI_SERVICE_QBAUTH = 'QBAuthentication'
NSI_SERVICE_QBEXPORT = 'QBDataExport'
NSI_SERVICE_LOGIN = 'TimeCardLogin'
NSI_SERVICE_CLIENT = 'Client'
NSI_SERVICE_MATTER = 'Matter'
NSI_SERVICE_TIMEKEEPER = 'TimeKeeper'
NSI_SERVICE_TIMECARD = 'TimeCard'
NSI_SERVICE_TIMECARD_COLLECTION = 'TimeCardCollection'
NSI_SERVICE_TIMECARD_REPORT = 'TimeCardReport'
NSI_SERVICE_TIMECARD_SYNC = 'TimeCardSync'
NSI_SERVICE_MATTER_SYNC = 'MatterSync'
NSI_SERVICE_CLIENT_SYNC = 'ClientSync'
NSI_SERVICE_TIMEKEEPER_SYNC = 'TimeKeeperSync'
NSI_SERVICE_SYNC_STATUS = 'SyncStatus'
NSI_SERVICE_DASHBOARD = 'UserDashboard'
NSI_SERVICE_USER = 'User'
NSI_SERVICE_USER_REG = 'UserReg'
NSI_SERVICE_ROLE = 'Role'
NSI_SERVICE_USER_ROLE = 'UserRole'
NSI_SERVICE_ROLE_PERMISSION = 'ServiceObjectRole'
NSI_SERVICE_USER_SETTING = 'UserSetting'
NSI_SERVICE_LOCALIZATION_DATA = 'LocalizationData'
NSI_SERVICE_USER_LOCALITY = 'UserLocality'
NSI_SERVICE_DATE_FORMAT = 'DateFormat'
NSI_SERVICE_TIME_FORMAT = 'TimeFormat'
NSI_SERVICE_NUMBER_FORMAT = 'NumberFormat'
NSI_SERVICE_LOCALITY = 'Locality'
NSI_SERVICE_TIMECARD_SUMMARY = 'TimecardSummary'
NSI_SERVICE_TIMECARD_STATUS = 'TimeCardStatus'
NSI_SERVICE_ERP_USER = 'ErpUser'
NSI_SERVICE_SERVICE_MODE = 'ServiceMode'
NSI_SERVICE_FARM_SETTING = 'FarmSetting'

NSI_SERVICE_AUTOCOMPLETE = "AutoCompleteList"

NSI_SERVICE_PARAM_KEY_MATTERNUMBER = 'matternumber'
NSI_SERVICE_PARAM_KEY_CLIENTNUMBER = 'clientnumber'
NSI_SERVICE_PARAM_KEY_TIMEKEEPERNUMBER = 'timekeepernumber'
NSI_SERVICE_PARAM_KEY_TIMEKEEPERNAME = 'timekeepername'
NSI_SERVICE_PARAM_KEY_TCBILLDATEFROM = 'tcbilldatefrom'
NSI_SERVICE_PARAM_KEY_TCBILLDATETO = 'tcbilldateto'
NSI_SERVICE_PARAM_KEY_TCBILLSTATUS = 'tcbillstatus'
NSI_SERVICE_PARAM_KEY_TCAPPROVED = 'tcapproved'
NSI_SERVICE_PARAM_KEY_TCSYNCED = 'tcsynced'
NSI_SERVICE_PARAM_KEY_TEMPLATE = 'template'
NSI_SERVICE_PARAM_KEY_NARRATIVE = 'narrative'
NSI_SERVICE_PARAM_KEY_INTERNAL_COMMENT = 'internalcomment'

NSI_AUTH_SUCCESS = '2001'
NSI_AUTH_FAILED = '2002'
NSI_ERROR_NOT_AUTHORIZED = '2003'
NSI_ERROR_SUCCESS = '0';
NSI_ERROR_FAILED = '1';
NSI_ERROR_NOT_SUPPORTED = '2';
NSI_ERROR_ERP_NOT_AVAILABLE = '8';

NSI_DEVICE_KEY = 'deviceid'
NSI_DEVICE_VALUE = 'nsiweb'
NSI_SYNC_SOURCE = 'syncsource'
NSI_SYNC_KEY_ERP = 'ERP'
NSI_SYNC_KEY_DEVICE = 'Device'
NSI_KEY_ISROLEBASEDQUERY = "isrolebasedquery";
NSI_KEY_REPORT_TYPE = "report_type";
NSI_KEY_REPORT_TYPE_TEXT = "report_type_text";
NSI_KEY_REPORT_TYPE_PDF = "report_type_pdf";

SESSION_LOGIN_INDEX = 0
SESSION_PASSWORD_INDEX = 1
SESSION_USERNAME_INDEX = 2
SESSION_ID_INDEX = 3

GENERIC_ERROR_MESSAGE = 'An error occurred'
GENERIC_FATAL_ERROR_MESSAGE = 'An error occurred'
GENERIC_NON_AUTHORIZED_MESSAGE = 'You do not have enough permission to view the contents of this page'
OPERATION_NON_AUTHORIZED_MESSAGE = 'You do not have enough permission to perform the action'
GENERIC_NO_DATA_MESSAGE = 'No data found'

TIMECARD_INSERT_SUCCESS_MESSAGE = 'Timecard has been created successfully'
TIMECARD_POST_SUCCESS_MESSAGE = 'Timecard has been posted successfully'
TIMECARD_UPDATE_SUCCESS_MESSAGE = 'Timecards have been updated successfully'
TIMECARD_DELETE_SUCCESS_MESSAGE = 'Timecard has been deleted successfully'
TIMECARD_SYNC_SUCCESS_MESSAGE = 'Timecards have been synced successfully'
TIMECARD_SYNC_NOT_SUPPORTED_MESSAGE = 'Timecard sync is not supported'
TIMECARD_INVALID_MESSAGE = 'Invalid timecard'
TIMECARD_NOT_EDITABLE_MESSAGE = 'Timecard is not editable/deletable for unknown reason'
MATTER_SYNC_SUCCESS_MESSAGE = 'Matters have been synced successfully'
MATTER_INSERT_SUCCESS_MESSAGE ='Matter has been created successfully'
MATTER_UPDATE_SUCCESS_MESSAGE = 'Matter has been updated successfully'
MATTER_DELETE_SUCCESS_MESSAGE = 'Matter has been deleted successfully'
SYNC_ALL_SUCCESS_MESSAGE = 'Timekeepers, Clients, Matters and Timecards have been synced successfully'
PLEASE_WAIT_MESSAGE = 'Please wait...'
MATTER_SYNC_NOT_SUPPORTED_MESSAGE = 'Matter sync is not supported'
CLIENT_SYNC_SUCCESS_MESSAGE = 'Clients have been synced successfully'
CLIENT_SYNC_NOT_SUPPORTED_MESSAGE = 'Client sync is not supported'
CLIENT_INSERT_SUCCESS_MESSAGE = 'Client has been created successfully'
CLIENT_UPDATE_SUCCESS_MESSAGE = 'Client has been updated successfully'
CLIENT_DELETE_SUCCESS_MESSAGE = 'Client has been deleted successfully'
TIMEKEEPER_SYNC_SUCCESS_MESSAGE = 'Timekeepers have been synced successfully'
TIMEKEEPER_SYNC_NOT_SUPPORTED_MESSAGE = 'Timekeeper sync is not supported'
USER_INSERT_SUCCESS_MESSAGE = 'User has been created successfully'
USER_REG_SUCCESS_MESSAGE = 'Thank you for signup. An email has been sent to your account.'
USER_PASSWORD_SUCCESS_MESSAGE = 'New password has been sent to your email address.'
TIMEKEEPER_INSERT_SUCCESS_MESSAGE = 'Timekeeper has been created successfully'
TIMEKEEPER_UPDATE_SUCCESS_MESSAGE = 'Timekeeper has been updated successfully'
TIMEKEEPER_DISABLE_SUCCESS_MESSAGE = 'Timekeeper has been disabled successfully'
NEWUSER_CREATE_SUCCESS_MESSAGE = 'New user has been created successfully'
ACTIVITYCODE_DISABLE_SUCCESS_MESSAGE = 'Activitycode has been disabled successfully'
ACTIVITYCODE_INSERT_SUCCESS_MESSAGE = 'Activitycode has been created successfully'
ACTIVITYCODE_UPDATE_SUCCESS_MESSAGE = 'Activitycode has been updated successfully'
ACTIVITYCODE_DELETE_SUCCESS_MESSAGE = 'Activitycode has been deleted successfully'

USER_UPDATE_SUCCESS_MESSAGE = 'User has been updated successfully'
USER_DELETE_SUCCESS_MESSAGE = 'User has been deleted successfully'
USER_INVALID_MESSAGE = 'Invalid user'
TIMEKEEPER_INVALID_MESSAGE = 'Invalid timekeeper'
REGSITEREDUSER_INVALID_MESSAGE = "Invalid user"
ACTIVITYCODE_INVALID_MESSAGE = 'Invalid activity code'
ROLE_INSERT_SUCCESS_MESSAGE = 'Role has been created successfully'
ROLE_UPDATE_SUCCESS_MESSAGE = 'Role has been updated successfully'
ROLE_DELETE_SUCCESS_MESSAGE = 'Role has been deleted successfully'
ROLE_INVALID_MESSAGE = 'Invalid role'
PASSWORD_CHANGE_OLD_PWD_MISMATCH = "Old password doesn't match"
PASSWORD_CHANGE_NEW_PWD_MISMATCH = "Confirmed password doesn't match with the new password"
PASSWORD_CHANGE_ERROR = "Couldn't change password"
PASSWORD_CHANGE_SUCCESS = "Password has been changed successfully"
USER_SETTING_CHANGE_SUCCESS = "User setting updated successfully"
USER_SETTING_CHANGE_ERROR = "Couldn't update user setting"
##ERP->TnB
 #Robert
 #07-16-2013
##
USER_SETTING_ERP_ID_SAVE_ERROR = "TnB user ID wasn't saved due to TnB unavailability"
USER_SETTING_ERP_ID_DUPLICATE_ERROR = "TnB User ID already exists"
USER_LOCALITY_CHANGE_SUCCESS = "Locale has been updated successfully"
USER_LOCALITY_CHANGE_ERROR = "Couldn't update locale"
USER_LOCALITY_RESET_SUCCESS = "Locale has been reset successfully"
USER_LOCALITY_RESET_ERROR = "Couldn't reset locale"
FARM_SETTING_CHANGE_SUCCESS = "Firm settings have been updated successfully"
FARM_SETTING_CHANGE_ERROR = "Couldn't update firm settings'"
FARM_SETTING_ADD_SUCCESS = "Firm have been assigned successfully"
FARM_SETTING_ADD_ERROR = "Couldn't add firm settings'"

SESSION_TIMECARD_PAGE_SIZE_KEY = 'SESSION_TIMECARD_PAGE_SIZE_KEY'
TIMECARD_PAGE_SIZE = 10
SESSION_TIMECARD_REPORT_PAGE_SIZE_KEY = 'SESSION_TIMECARD_REPORT_PAGE_SIZE_KEY'
TIMECARD_REPORT_PAGE_SIZE = 15
SESSION_USER_PAGE_SIZE_KEY = 'SESSION_USER_PAGE_SIZE_KEY'
USER_PAGE_SIZE = 10
SESSION_ROLE_PAGE_SIZE_KEY = 'SESSION_ROLE_PAGE_SIZE_KEY'
ROLE_PAGE_SIZE = 8
SESSION_TIMEKEEPER_PAGE_SIZE_KEY = 'SESSION_TIMEKEEPER_PAGE_SIZE_KEY'
TIMEKEEPER_PAGE_SIZE = 10

USER_SETTING_PAGE_SIZE = 100  #assume that no more than 100 settings will be needed(for 1 user), (if needed in future change the size)
SESSION_TNB_USER_ID = 'TNB_USER'

TIMECARD_DEFUALT_REFERENCE_VALUE = '5'

SESSION_COMPANY_ID = 'SESSION_COMPANY_ID'
SESSION_CONSUMER_KEY = 'SESSION_CONSUMER_KEY'
SESSION_CON_SECRET = 'SESSION_CON_SECRET'
SESSION_EXPIRE_DATE = '0'
SESSION_OAUTH_TOKEN = 'SESSION_OAUTH_TOKEN'
SESSION_OAUTH_SECRET = 'SESSION_OAUTH_SECRET'
SESSION_RELMID = 'SESSION_RELMID'
SESSION_OAUTH_VERIFIER = 'SESSION_OAUTH_VERIFIER'

SESSION_CUSTOMER_REF='SESSION_CUSTOMER_REF'
SESSION_DEPT_REF='SESSION_DEPT_REF'
SESSION_ITEM_REF='SESSION_ITEM_REF'
SESSION_CLASS_REF='SESSION_CLASS_REF'


SESSION_USER_SUBSCRIPTION_REMAIN_DAYS_ERRORCODE = '0'
SESSION_USER_SUBSCRIPTION_REMAIN_DAYS_MSG = ''
APP_VERSION = '2.1'
APP_RELEASE_DATE = "12-29-2014"
APP_INSTANCE = 'NSITest'
SESSION_FARM_NAME = "FARM_NAME"
SESSION_SYNC_ENABLE = '0'
