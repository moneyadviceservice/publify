class AddSupportsAmpToContent < ActiveRecord::Migration
  NON_AMP_ARTICLES = [
    461, 607, 834, 213, 231, 244, 806, 251, 259, 271, 286, 297, 313,
    316, 323, 325, 326, 330, 331, 332, 336, 338, 339, 341, 344, 345,
    346, 349, 351, 355, 356, 360, 361, 368, 371, 384, 406, 411, 415,
    416, 434, 451, 452, 464, 474, 475, 492, 498, 499, 509, 513, 535,
    544, 550, 552, 554, 559, 569, 575, 581, 583, 590, 595, 601, 603,
    811, 616, 619, 623, 627, 638, 646, 647, 657, 820, 659, 664, 673,
    676, 679, 685, 701, 702, 703, 705, 706, 722, 724, 742, 744, 751,
    788, 792, 795, 799, 821, 835, 843, 845, 856, 866, 868, 900, 910
  ]

  def up
    add_column :contents, :supports_amp, :boolean, default: true
    Article.where(id: NON_AMP_ARTICLES).update_all("supports_amp = false")
  end

  def down
    remove_column :contents, :supports_amp
  end
end
