import os

from boto.sqs.connection import SQSConnection

AWS_SQS_ACCESS_KEY_ID = os.environ['AWS_SQS_ACCESS_KEY_ID']
AWS_SQS_SECRET_ACCESS_KEY = os.environ['AWS_SQS_SECRET_ACCESS_KEY']


conn = SQSConnection(AWS_SQS_ACCESS_KEY_ID, AWS_SQS_SECRET_ACCESS_KEY)
queue = conn.get_queue('panda-prod-bulk_upload')


while 1:
     messages = queue.get_messages(num_messages=10, wait_time_seconds=5)
     for m in messages:
         queue.delete_message(m)
     if len(messages) == 0:
         break

print "done"
