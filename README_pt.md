
# Inventory Slot Plugin
  O Inventory Slot Plugin é um addon para Godot 4.3.x, desenvolvido para simplificar e agilizar a implementação de sistemas de inventário em jogos. Com uma interface intuitiva e um sistema robusto, ele permite que você gerencie itens de forma eficiente.


<img alt="Static Badge" src="https://img.shields.io/badge/current%20version-0.5.1-red"> <img alt="Static Badge" src="https://img.shields.io/badge/godot%20version-4.3.x.stable-blue">

# Sumario

- [Instalação](#instalação)
- [Como Usar](#como-usar)
- [Codigo e Funções](#codigo-e-funções)
  
# Instalação
Baixar o Repositório:
    Após baixar o arquivo `.zip` do plugin, abra seu projeto na Godot.

Importar o Plugin:
    Vá até a janela de AssetLib e clique em `"Importar Plugins"`.

![image](https://github.com/user-attachments/assets/27baefb5-0270-48c6-a943-e276f317e269)

Localizar o Arquivo:
    Encontre o arquivo do plugin que você baixou.

Reiniciar o Projeto:
    É normal que apareçam alguns erros após a importação. Reinicie o projeto para garantir que tudo esteja funcionando corretamente.


# Como Usar

  A forma de se usar o plugin é simples e bem flexivel com projetos.

### 1.Crie painéis e os configure com sua preferencia.

![image](https://github.com/user-attachments/assets/ba8bc02f-970f-4d62-8eea-ef472f5c52c8)


### 2.Um pouco mais abaixo terá o painel  Class / Items, onde será criado suas classes e seus itens.

![image](https://github.com/user-attachments/assets/4238cfe7-c616-4225-8c39-deb48334ef22)


### 3.Com as configurações inicias feitas já podemos por nossa interface em ação. Adicione o node PanelSlot em sua cena.

![image](https://github.com/user-attachments/assets/65e612b6-0cf2-4f00-b58a-e613d45510b1)

### 4.Agora vamos configurar o nosso painel para receber os itens adequadamente.

![image](https://github.com/user-attachments/assets/b22fdc9d-bb5e-4d13-a357-b919f441adcf)

### 5.Está tudo pronto, mas precisamos saber como nossa interface está funcionando. E para isto iremos adicionar um item via código de forma simples usando add_item() do singleton Inventory:

    func _ready() -> void:
        Inventory.add_item(1,0)

![image](https://github.com/user-attachments/assets/8d5a9e48-0dd9-40a2-b13e-84f70056de73)

# Codigo e funções

  Aqui temos 2 recursos para manipular itens/arquivos.

## Inventory ( Singleton )
  Manipulação de itens em inventario.

  #### Usando o `add_item()`, você adiciona ao inventario o item especificando o `_item_unique_id` e direcionando o painel em `_panel_id`. 
    Inventory.add_item(_panel_id: int, _item_unique_id: int, _amount: int = 1, _slot: int = -1, _id: int = -1, _unique: bool = false)
  #### Remova o item de um painel, entregue o id do painel para `_panel_id`, e o `id` do item no inventario.
    Inventory.remove_item(_panel_id: Dictionary, _id: int = -1)
  #### Procure itens de um painel usando `search_item`, entregue o `unique_id` do item em `_item_unique_id`.
    Inventory.search_item(_panel_id: int, _item_unique_id: int = -1, _path : String = "",_slot: int = -1)
  #### Troque itens de paineis.
    Inventory.set_panel_item(_item_id: int, _out_panel_id: int, _new_panel_id:int, _slot: int = -1, _unique: bool = false, _out_item_remove: bool = true)
  #### Troque o slot de um item.
    Inventory.set_slot_item(_panel_item: Dictionary, _item_inventory: Dictionary, _slot: int = -1, _unique: bool = true)
  #### Troque 2 itens de slots.
    Inventory.func changed_slots_items(item_one: Dictionary, item_two: Dictionary)`


## InventoryFile ( Class )
  Manipulação dos arquivos.
  
  #### Procure um item em painel usando `unique_id`.
    search_item_id(_panel_id: int, _item_unique_id: int = -1)
  #### Pegue um painel com o id do proprio.
    get_panel(_panel_id: int)
  #### Pegue um painel com o `unique_id` de um item em inventario que esteja dentro do proprio.
    get_panel_id(_unique_id: int)
  #### Retorna o nome do item
    get_class_name(_unique_id_item: int)
  #### Retorna o nome da classe do item
    get_item_name(_unique_id_item: int)
  #### Verifique se o arquivo é um json ( vai além da extensão ).
    InventoryFile.is_json(_path: String)
  #### Pegue o json em dicionario.
    InventoryFile.pull_inventory(_path: String)
  #### Envie seu dicionario para ser salvo em json parar `_path`.
    InventoryFile.push_inventory(_dic: Dictionary,_path: String)
  #### Adicione o item diretamente em `ITEM_INVENTORY_PATH`.
    InventoryFile.push_item_inventory(_item_id: int, _item_inventory: Dictionary)
  #### Crie uma nova classe.
    new_class(_class_name: String)
  #### Crie um item em painel.
    new_item_panel(_class_name: String,_icon_path: String = InventoryFile.IMAGE_DEFAULT,_amount: int = 1,_description: String = "",_path_scene: String = "res://")
  #### Remova uma classe.
    remove_class(_inventory: Dictionary,_class_name: String)
  #### Remova um item em painel.
    remove_item(_inventory: Dictionary,_class_name: String,_item_name: String)
  
  ### Para `_path` existe caminhos predefinidos:
   `ITEM_PANEL_PATH`
   `PANEL_SLOT_PATH`
   `ITEM_INVENTORY_PATH`

