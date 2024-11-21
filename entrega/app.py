from flask import Flask, render_template, request, redirect, url_for, flash,  session
from flask_mysqldb import MySQL
from datetime import datetime


app = Flask(__name__)
app.secret_key = 'Samuel'  



app.config['MYSQL_HOST'] = 'sql5.freemysqlhosting.net'  # Cambiar por el host de tu servidor
app.config['MYSQL_USER'] = 'sql5746201'       # Cambiar por tu usuario de MySQL
app.config['MYSQL_PASSWORD'] = 'EBbimy7Fg9'       # Cambiar por tu contraseña
app.config['MYSQL_DB'] = 'sql5746201'  # Cambiar por el nombre de tu base de datos

# Crear la instancia de MySQL
mysql = MySQL(app)


@app.route('/', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        nombre = request.form['nombre']
        contrasena = request.form['contrasena']

        
        cursor = mysql.connection.cursor()
        cursor.execute("SELECT ID_Usuario, Nombre, Password FROM USUARIO WHERE nombre = %s", (nombre,))
        user = cursor.fetchone()
        cursor.close()

        if user:
           
            if user[2] == contrasena:  
                session['username'] = user[1]  
                return redirect(url_for('tienda'))  
            else:
                flash('Contraseña incorrecta. Inténtalo de nuevo.', 'error')
        else:
            flash('Usuario no encontrado. Inténtalo de nuevo.', 'error')
    
    return render_template('index.html')


@app.route('/register', methods=['GET', 'POST'])
def register():
    if request.method == 'POST':
        nombre = request.form['nombre']
        contrasena = request.form['contrasena']

        
        cursor = mysql.connection.cursor()
        cursor.execute("SELECT * FROM USUARIO WHERE nombre = %s", (nombre,))
        user = cursor.fetchone()

        if user:
            flash('El nombre de usuario ya está registrado. Intenta otro.', 'error')
        else:
            
            cursor.execute("INSERT INTO USUARIO (Nombre,Rol, Password) VALUES (%s, 2, %s)", (nombre, contrasena))
            mysql.connection.commit()
            cursor.close()
            flash('Usuario registrado con éxito. Ahora puedes iniciar sesión.', 'success')
            return redirect(url_for('login'))

    return render_template('registro.html')




@app.route('/opiniones')
def opiniones():
    return render_template('opiniones.html')  



@app.route('/tienda')
def tienda():
    if 'username' not in session:
        return redirect(url_for('login'))  
    cursor = mysql.connection.cursor()
    cursor.execute("""
        SELECT ID_Producto, Nombre, Descripción, CAST(Precio AS UNSIGNED), Stock, Img
        FROM PRODUCTO
    """)
    products = cursor.fetchall()
    cursor.close()

    return render_template("tienda.html", products=products, username=session['username'])






@app.route("/comprar/<int:product_id>")
def product_details(product_id):
    cursor = mysql.connection.cursor()
    cursor.execute("SELECT ID_Producto, Nombre, Descripción, Precio, Stock, Img FROM PRODUCTO WHERE ID_Producto = %s", (product_id,))
    product = cursor.fetchone()  
    cursor.close()
    
    if product:
       
        product = list(product)  
        product[3] = int(product[3])  
        return render_template("detalles.html", product=product)
    else:
        return "Producto no encontrado", 404



@app.route('/comprar/<int:product_id>', methods=['GET', 'POST'])
def comprar(product_id):
    if request.method == 'POST':
        
        direccion_envio = request.form['direccion_envio']
        metodo_pago = request.form['metodo_pago']
        cantidad_comprada = int(request.form['cantidad'])  
        
        
        if 'username' not in session:
            return redirect(url_for('login'))  

        username = session['username']
        
        
        cursor = mysql.connection.cursor()
        cursor.execute("SELECT ID_Cliente FROM CLIENTE WHERE nombre = %s", (username,))
        cliente = cursor.fetchone()

        if cliente:  
            cliente_id = cliente[0]
        else:  
            cursor.execute("INSERT INTO CLIENTE (nombre) VALUES (%s)", (username,))
            mysql.connection.commit()
            cliente_id = cursor.lastrowid  

        
        cursor.execute("SELECT stock, precio FROM PRODUCTO WHERE ID_Producto = %s", (product_id,))
        producto = cursor.fetchone()

        if not producto:
            flash("Producto no encontrado.", "danger")
            return redirect(url_for('home'))  

        stock_disponible = producto[0]
        precio_unitario = producto[1]

        
        if cantidad_comprada > stock_disponible:
            flash("No hay suficiente stock disponible para completar la compra.", "danger")
            return redirect(url_for('home'))  

        
        fecha = datetime.now().strftime('%Y-%m-%d %H:%M:%S')  
        cursor.execute("""
            INSERT INTO TRANSACCION (Fecha, ID_Cliente, Estado, Direccion_envio, pago)
            VALUES (%s, %s, %s, %s, %s)
        """, (fecha, cliente_id, 'pendiente', direccion_envio, metodo_pago))
        mysql.connection.commit()

        
        transaction_id = cursor.lastrowid

        
        bruto = precio_unitario * cantidad_comprada
        impuesto = (bruto /100) *10 
        neto = bruto + impuesto

        
        cursor.execute("""
            INSERT INTO DETALLES_TRANSACCION (ID_Producto, ID_Transaccion, Cantidad, Precio, Bruto, Impuesto, Neto)
            VALUES (%s, %s, %s, %s, %s, %s, %s)
        """, (product_id, transaction_id, cantidad_comprada, precio_unitario, bruto, impuesto, neto))
        mysql.connection.commit()

        
        nuevo_stock = stock_disponible - cantidad_comprada
        cursor.execute("""
            UPDATE PRODUCTO SET stock = %s WHERE ID_Producto = %s
        """, (nuevo_stock, product_id))
        mysql.connection.commit()

        flash("Compra realizada exitosamente.", "success")
        return render_template('compra_exitosa.html', producto_id=product_id, costo=neto)  

    return render_template('compra.html', producto_id=product_id)



@app.route('/logout')
def logout():
    session.pop('username', None)  
    return redirect(url_for('login'))  



if __name__ == '__main__':
    app.run(debug=True)