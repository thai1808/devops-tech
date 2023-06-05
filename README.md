### OBO STADIUM WEBSITE
Trang thương mại điện tử bán giày

### Chạy app bằng maven

```shell
mvn spring-boot:run
```

### Mockup dữ liệu ban đầu cho ứng dụng

Import file ```obo.sql``` vào MySQL. Sử dụng 2 account sau để đăng nhập vào web:

- Admin account:
    - Username: admin@obostadium.com
    - Password: 123456
- Member account:
    - Username: monguyen@gmail.com
    - Password: 123456
    

Truy cập ```/admin``` để vào trang admin.

### Built with
- [Java Spring](https://spring.io/) - The web framework used
- [Maven](https://mvnrepository.com/) - Dependency Management

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------

Project demo được lấy tại github: https://github.com/liamhubian/techmaster-obo-web

<h2> Bước 1: Triển khai cơ sở dữ liệu MySQL </h2>
Chạy container mysql:

```
docker run -d -p 3306:3306 --name obo-mysql -e MYSQL_ROOT_PASSWORD=123 -e MYSQL_DATABASE=obo mysql:latest
```

Copy file obo.sql vào container vừa tạo
```
docker cp obo.sql obo-mysql:/
```
Truy cập vào container và tiến hành import database
```
mysql -u root -p obo < obo.sql
```

<h2> Bước 2: cài đặt ứng dụng và đóng gói dưới dạng container </h2>
Chỉnh sửa cấu hình ở file application-dev.properties để phù hợp với thông tin database vừa tạo (Ảnh đính kèm: https://prnt.sc/dcp7WNu07uRy)

Tiến hành đóng gói ứng dụng, khởi chạy container obo-web để kiểm tra hoạt động của ứng dụng trước khi triển khai trên K8s
```
docker build -t obo-web:1.6 .
```
Ảnh đính kèm: https://prnt.sc/hnnzhrMEu_aP

Để vận dụng với ConfigMap, truy cập vào container obo-web:1.6 và thay đổi thông số, gán biến để triển khai K8s với ConfigMap (Ảnh đính kèm: https://prnt.sc/WtMQoXP0z4IX)

Đóng gói container và push lên Docker Hub

<h2> Bước 3: Triển khai ứng dụng trên môi trường K8s </h2>
Tạo configmap

```
kubectl create configmap obo-web-configmap --dry-run=client -o yaml > obo-webconfigmap.yaml
```
Khai báo thêm key:value để phù hợp với các biến đã chỉnh sửa ở file applicationdev.properties

```
cat obo-web-configmap.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  creationTimestamp: null
  name: obo-web-configmap
data:
  DB_HOST: "103.110.85.124"
  DB_PORT: "3306"
  DB_NAME: "obo"
  DB_USER: "root"
  DB_PASSWORD: "******"
```

Tạo deployment với image vừa push lên Docker Hub

```
kubectl create deployment obo-web --image minnthaii/obo-web:1.7 -o yaml --dryrun=client > obo-web-deployment.yaml
```


```
cat  obo-web-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  creationTimestamp: null
  labels:
    app: obo-web
  name: obo-web
spec:
  replicas: 1
  selector:
    matchLabels:
      app: obo-web
  strategy: {}
  template:
    metadata:
      creationTimestamp: null
      labels:
        app: obo-web
    spec:
      containers:
      - image: minnthaii/obo-web:1.7
        name: obo-web
        envFrom:
        - configMapRef:
            name: obo-web-configmap
        resources: {}
status: {}
```

Apply template:

```
kubectl create -f obo-web-configmap.yaml
kubectl create -f obo-web-deployment.yaml
```

Sử dụng lệnh kubectl get all để kiểm tra (Ảnh đính kèm: https://prnt.sc/C_wOWtD1o-u2)

<h2> Bước 4: Truy cập tới ứng dụng </h2>

```
kubectl port-forward deploy/obo-web --address 0.0.0.0 8081:8080
```

Truy cập thông qua port 8081 (Ảnh đính kèm: https://prnt.sc/fVSyCtg1JDmz , https://prnt.sc/J-CNpMQesmR7)

