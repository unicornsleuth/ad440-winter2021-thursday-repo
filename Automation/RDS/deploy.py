import boto3
import logging
import sys
from botocore.exceptions import ClientError

def deployTemplate():
    """Deploy RDS Stack using Cloudformation Template
    :param aws_access_key: Your personal AWS access key, not the gha-aws-access-key
    :param aws_access_secret: Your personal AWS access secret, not the gha-aws-access-secret
    :param DBUser: DB admin username for the RDS. 1-16 chars alphanumeric only
    :param DBPassword: DB admin password for the RDS. 8-41 chars alphanumeric only

    :returns: Response data from the stack deployment, 200 code if created
    """

    try:
        aws_access_key=sys.argv[1]
        aws_access_secret=sys.argv[2]
        stack_name=sys.argv[3]
        DBUser=sys.argv[4]
        DBPassword=sys.argv[5]
    except Exception:
        print('\nIncorrect # of system arguments. Please re-check your parameters')
        return

    try:
        # Set up boto3 session
        session = boto3.Session(
            aws_access_key_id=aws_access_key,
            aws_secret_access_key=aws_access_secret
        )
        # CloudFormation call
        rds_client = session.client('cloudformation', region_name='us-west-2')
        return rds_client.create_stack(
            StackName=stack_name,
            TemplateURL="https://s3.us-west-2.amazonaws.com/cloudformation-templates-us-west-2/RDS_PIOPS.template",
            Parameters=[
                {
                    'ParameterKey': 'DBUser',
                    'ParameterValue': DBUser,
                },
                {
                    'ParameterKey': 'DBPassword',
                    'ParameterValue': DBPassword,
                }
            ]
        )
    except ClientError as e:
        raise(e)

def main():
    
    response_data = deployTemplate()
    
    if response_data != None and response_data['ResponseMetadata']['HTTPStatusCode'] == 200:
        print('Response Data: ', response_data)
        print('\nOperation Successful')
    else:
        print('\nAn error occurred, see above error message.')

main()
