
**Plugin de Slot de Inventário**
O Plugin de Slot de Inventário é um addon para Godot 4.3.x, projetado para simplificar e acelerar a implementação de sistemas de inventário em jogos. Com uma interface intuitiva e um sistema robusto, ele permite gerenciar itens de forma eficiente.

**Pluguin Original:** https://github.com/BielyDev/Inventory_slot
**Fork com tradução em portugues:** https://github.com/WalneyNF/Inventory_slot
**Video explicativo:** https://www.youtube.com/watch?v=6-_zMce0Ah8

<img alt="Static Badge" src="https://img.shields.io/badge/current%20version-0.9.0-red"> <img alt="Static Badge" src="https://img.shields.io/badge/godot%20version-4.3.x.stable-blue">

**Sumário**
**Instalação**
**Como usar**

**Código e Funções**

**Instalação**
**Baixar o Repositório:** Após baixar o arquivo .zip do plugin, abra seu projeto no Godot.

**Importar o Plugin:** Vá até a janela AssetLib e clique em “Import Plugins”.

image

**Encontrar o Arquivo:** Localize o arquivo do plugin que você baixou.

**Reiniciar o Projeto:** É normal que alguns erros apareçam após a importação. Reinicie o projeto para garantir que tudo esteja funcionando corretamente.

**NOTA: IMPORTANTEMENTE, O PLUGIN PRECISA DA PASTA ADDONS.**

**Como usar**
**A maneira de usar o plugin é simples e muito flexível com projetos.**

**1. Crie painéis e configure-os como desejar.**
image

**2. Um pouco mais abaixo, você encontrará o painel Class / Items, onde criará suas classes e itens.**
image

**3. Com as configurações iniciais feitas, podemos colocar nossa interface em ação. Adicione o nó PanelSlot à sua cena.**
image

**4. Agora, vamos configurar nosso painel para receber os itens corretamente.**
image

**5. Tudo está pronto, mas precisamos saber como nossa interface está funcionando. E para isso, adicionaremos um item via código de forma simples usando add_item() do singleton Inventory:**

func _ready() -> void:
	Inventory.add_item(1,0)
image

**Código e Funções**
**Aqui temos 2 recursos para manipulação de itens/arquivos.**

# Inventory (Singleton)
**Manipulação de itens do inventário.**

- **Usando `add_item()`, você adiciona o item ao inventário especificando o `_item_unique_id` e direcionando o painel em `_panel_id`.**
  Inventory.add_item(_panel_id: int, _item_unique_id: int, _amount: int = 1, _slot: int = -1, _id: int = -1, _unique: bool = false)

  **Remove o item de um painel, forneça o id do painel em _panel_id e o id do item no inventário.**
Inventory.remove_item(_panel_id: Dictionary, _id: int = -1)

**Pesquise itens em um painel usando search_item, forneça o unique_id do item em _item_unique_id.**
Inventory.search_item(_panel_id: int, _item_unique_id: int = -1, _path : String = "",_slot: int = -1)

**Troca itens de painéis.**
Inventory.set_panel_item(_item_id: int, _out_panel_id: int, _new_panel_id:int, _slot: int = -1, _unique: bool = false, _out_item_remove: bool = true)

**Altera o slot de um item.**
Inventory.set_slot_item(_panel_item: Dictionary, _item_inventory: Dictionary, _slot: int = -1, _unique: bool = true)

**Troca 2 itens de slot.**
Inventory.func changed_slots_items(item_one: Dictionary, item_two: Dictionary)
InventoryFile (Classe)

**Manipulação de arquivos.**

**Pesquise um item em um painel usando unique_id.**
search_item_id(_panel_id: int, _item_unique_id: int = -1)

**Obtenha um painel com seu próprio id.**
get_panel(_panel_id: int)

**Obtenha um painel com o unique_id de um item no inventário que esteja dentro dele.**
get_panel_id(_unique_id: int)

**Retorna o nome do item.**
get_class_name(_unique_id_item: int)

**Retorna o nome da classe do item.**
get_item_name(_unique_id_item: int)

**Verifica se o arquivo é um json (vai além da extensão).**
InventoryFile.is_json(_path: String)

**Extrai o json do dicionário.**
InventoryFile.pull_inventory(_path: String)

**Envia seu dicionário para ser salvo em json no _path.**
InventoryFile.push_inventory(_dic: Dictionary,_path: String)

**Adiciona o item diretamente ao ITEM_INVENTORY_PATH.**
InventoryFile.push_item_inventory(_item_id: int, _item_inventory: Dictionary)

**Cria uma nova classe.**
new_class(_class_name: String)

**Cria um item em um painel.**
new_item_panel(_class_name: String,_icon_path: String = InventoryFile.IMAGE_DEFAULT,_amount: int = 1,_description: String = “”,_path_scene: String = “res://”)

**Remove uma classe.**
remove_class(_inventory: Dictionary,_class_name: String)

**Remove um item em um painel.**
remove_item(_panel_id: int, _id: int = -1)

**Lista todos os painéis em um array.**
list_all_panel()

Const
ITEM_PANEL_PATH
PANEL_SLOT_PATH
ITEM_INVENTORY_PATH
