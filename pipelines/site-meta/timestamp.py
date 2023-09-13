import os
import sys
import datetime

if __name__ == '__main__':
    target = sys.argv[1]
    os.makedirs(os.path.dirname(target), exist_ok=True)
    with open(target, 'w') as f:
        f.write(
          datetime.datetime.utcnow().replace(tzinfo=datetime.timezone.utc).replace(microsecond=0).isoformat()
        )