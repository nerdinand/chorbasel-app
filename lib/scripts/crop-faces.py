import cv2 
import os

directory = 'chorbasel.onepage.me-1731198496943'

face_cascade = cv2.CascadeClassifier('haarcascade_frontalface_alt2.xml') 

for filename in os.listdir(directory):
  path = os.path.join(directory, filename)

  img = cv2.imread(path)     
  gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY) 
  faces = face_cascade.detectMultiScale(gray, 1.1, 4) 

  original_width = 2880
  original_height = 3886

  wanted_width = 1600
  wanted_height = 1600

  center_ratio_width = 0.6
  center_ratio_height = 0.6

  center_min_x = ((1.0 - center_ratio_width) / 2) * original_width
  center_max_x = original_width - center_min_x

  center_min_y = ((1.0 - center_ratio_height) / 2) * original_height
  center_max_y = original_height - center_min_y

  i = 0
  for (x, y, w, h) in faces:
    center_x = x + w / 2
    center_y = y + h / 2

    if not (center_min_x < center_x < center_max_x and center_min_y < center_y < center_max_y):
      continue
    
    i += 1

    min_y = int(center_y - wanted_height/2)
    max_y = int(center_y + wanted_height/2)
    min_x = int(center_x - wanted_width/2)
    max_x = int(center_x + wanted_width/2)

    if not (0 <= min_y <= original_height and 0 <= max_y <= original_height and 0 <= min_x <= original_width and 0 <= max_x <= original_width):
      continue

    face = img[min_y:max_y, min_x:max_x]
    # print(min_y, max_y, min_x, max_x)
    cv2.imwrite(f"{filename}-face-{i}.jpg", face)

  if i == 0:
    print(f"No face found in {filename}")

