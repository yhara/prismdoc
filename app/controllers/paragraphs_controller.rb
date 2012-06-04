class ParagraphsController < ApplicationController
  def update
    para = Paragraph.find(params[:id])
    
    if para.update_attributes(params[:paragraph])
      render text: para.html
    else
      render json: para.errors, status: :unprocessable_entity
    end
  rescue ActiveRecord::ResourceNotFound
    head :not_found
  end
end
