ActiveAdmin.register Product do
  permit_params :nombre, :descripcion, :precio, :stock

  index do
    selectable_column
    id_column
    column :nombre
    column :descripcion
    column :precio
    column :stock
    actions
  end

  form do |f|
    f.inputs 'Detalles del producto' do
      f.input :nombre
      f.input :descripcion
      f.input :precio
      f.input :stock
    end
    f.actions
  end

  controller do
    def create
      super do |success, _failure|
        success.html do
          redirect_to new_admin_product_path, notice: '¡Producto creado correctamente! Puedes crear otro.'
        end
      end
    end
  end
end
