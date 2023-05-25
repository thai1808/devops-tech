Đề bài
LEVEL 2: triển khai deployment một ứng dụng web tĩnh lên kubernetes cho phép truy cập từ bên ngoài thông qua nodePort

output:

đóng gói thành công container chứa web tĩnh
download 1 template tại https://www.free-css.com/free-css-templates)
sử dụng base image nginx
lưu ý cấu hình nginx trỏ tới web tĩnh (tham khảo file cấu hình mẫu đơn giản tại https://gist.github.com/mockra/9062657)
1 deployment chạy ứng dụng web tĩnh (replicas=2)
1 nodePort service trỏ tới deployment (service web 1)
thực hiên curl tới nodePort và cho ra kết quả trang web tĩnh theo template

---------------------------------------------------------------------------------------------------------------------------------------

Bước 1: tạo deployment với image nginx và replicas=2
```
$ kubectl create deployment static-web2 --image nginx:latest --replicas=2 --dry-run=client -o yaml > static-web2.yaml
```

Nội dung file:
```
cat static-web2.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  creationTimestamp: null
  labels:
    app: static-web2
  name: static-web2
spec:
  replicas: 2
  selector:
    matchLabels:
      app: static-web2
  strategy: {}
  template:
    metadata:
      creationTimestamp: null
      labels:
        app: static-web2
    spec:
      volumes:
      - name: static-web3
        hostPath:
          path: /home/thai/hostweb/html
      containers:
      - image: nginx
        name: nginx
        resources: {}
        volumeMounts:
        - name: static-web3
          mountPath: /usr/share/nginx/html
status: {}                                                                                                                                                                                                                                                                                                                  
```
Tạo deployment:
```
kubectl create -f static-web2.yaml
```

Bước 2: Tạo NodePort Service
```
kubectl create service nodeport static-web2 --tcp=8081:80 --dry-run=client -o yaml > static-web-svc.yaml
```
Nội dung file static-web-svc.yaml:
```
apiVersion: v1
kind: Service
metadata:
  creationTimestamp: null
  labels:
    app: static-web2
  name: static-web2
spec:
  ports:
  - name: 8081-80
    port: 8081
    protocol: TCP
    targetPort: 80
  selector:
    app: static-web2
  type: NodePort
status:
  loadBalancer: {}
```

Kiểm tra trạng thái của service sau khi tạo: https://prnt.sc/kdS-G06fjhys , https://prnt.sc/LZHsccNurArS

Truy cập đến ứng dụng thông qua port 30675: https://prnt.sc/U-4CTob84yxL

  


