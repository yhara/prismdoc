module ViewHelper
  def render_tree(tree, &block)
    return if tree.empty?

    concat "<ul>".html_safe
    tree.each do |parent, children|
      if children.empty?
        concat "<li>".html_safe
        block.call(parent)
        concat "</li>".html_safe
      else
        concat "<li><a class='tree_button' href='#'>[-]</a>".html_safe
        concat "<span>".html_safe
        block.call(parent)
        concat "</span>".html_safe
        render_tree(children, &block)
        concat "</li>".html_safe
      end
    end
    concat "</ul>".html_safe
  end
end
