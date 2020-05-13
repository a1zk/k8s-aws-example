#!/usr/bin/env python3
import boto3
import logging
from botocore.exceptions import ClientError
import argparse, textwrap
import random
import string 
import sys


# Help section
parser = argparse.ArgumentParser(prog='Terraform Init script', formatter_class=argparse.RawDescriptionHelpFormatter,
                                description=textwrap.dedent('''\
    How to use this script:
   -------------------------------
   This scrip create S3 bucket and DynamoDB table for saving and locking Terraform state file
   
   >>> NOTE: you have to be sure that AWS Configuration is set(Details here: https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html).

    ------------------------------
    Usage:
    ./terraform_init.py -n/--new <'bucket/table_name'>(default: "terraform-state-some_id") - create bucket and table
    ------------------------------

'''))
parser._positionals.title = "Arguments:"
parser.add_argument('-n','--new', help="create new bucket and DynomoDB table")
args = parser.parse_args()

# Default name of bucket and table
def_name = 'terraform-state'
print("\n")
print(" ===== Terraform init Script =====")
print("For more options use {} --h \n".format(sys.argv[0]))


def create(name=def_name):
    ran = ''.join([random.choice(string.ascii_lowercase 
            + string.digits) for n in range(5)])
    uniq_name = name + '-' +ran
    table_name = name+ '-' +"lock"
    # Create bucket
    try:
        s3 = boto3.client("s3")
        s3.create_bucket(Bucket=uniq_name, ACL='private',)
        s3.put_bucket_versioning(Bucket=uniq_name, VersioningConfiguration={'Status': 'Enabled'})
    except ClientError as e:
        logging.error(e)
        return False
    # Create DynamoDB table
    try:
        dynamodb = boto3.resource('dynamodb')
        table = dynamodb.create_table(
            TableName=table_name,
            KeySchema=[
                {
                    'AttributeName': 'LockID',
                    'KeyType': 'HASH'
                }
            ],
            AttributeDefinitions=[
                {
                    'AttributeName': 'LockID',
                    'AttributeType': 'S'
                }
            ],
            ProvisionedThroughput={
                'ReadCapacityUnits': 5,
                'WriteCapacityUnits': 5
                }
        )
        table.meta.client.get_waiter('table_exists').wait(TableName=table_name)
    except ClientError as er:
        logging.error(er)
        return False
    return uniq_name, table_name


def main():
    if args.new:
        b,t = create(args.new)
        print("Bucket {} has been craeted\n".format(b))
        print("Table {} has been craeted\n".format(t))
    else:
        b,t = create()
        print("Bucket with default name {} has been craeted\n".format(b))
        print("Table with default name {} has been craeted\n".format(t))

if __name__ == "__main__": 
    main()