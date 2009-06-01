class BundlesController < ApplicationController

  def new
    @bundle = Bundle.new
    @bundle.tags << Tag.from_list(params[:tag_list]) if params[:tag_list]
    if params[:scratchpad_id] && @expad = Scratchpad.find(params[:scratchpad_id])
      @members = @expad.scraps.uniq
      @bundle.name = @expad.name if @bundle.name.blank?
      @bundle.body = @expad.body if @bundle.body.blank?
    end
  end

  def create
    @bundle = Bundle.new(params[:bundle])
    @expad = Scratchpad.find(params[:scratchpad_id]) if params[:scratchpad_id]
    if @bundle.save
      @bundle.tags << Tag.from_list(params[:tag_list]) if params[:tag_list]
      if @expad
        logger.warn "!!! turning pad into bundle: pad is #{@expad.name}"
        Bundle.transaction {
          logger.warn "!!! and we have #{@expad.scraps.uniq.size} scraps to move"
          @bundle.members = @expad.scraps.uniq
          @expad.destroy
        }
        flash[:notice] = "Bundle created from scratchpad #{@expad.name}"
      else
        flash[:notice] = 'Bundle created'
      end
      redirect_to :controller => 'bundles', :action => 'show', :id => @bundle
    else
      render :action => 'new'
    end
  end

  def edit
    @bundle = Bundle.find(params[:id])
  end

  def update
    @bundle = @thing = Bundle.find(params[:id])
    if @bundle.update_attributes(params[:bundle])
      @bundle.taggings.clear
      @bundle.tags << Tag.from_list(params[:tag_list])
      flash[:notice] = 'Bundle was successfully updated.'
      redirect_to :action => 'show', :id => @bundle
    else
      render :action => 'edit'
    end
  end

  def destroy
    Bundle.find(params[:id]).destroy
    respond_to do |format|
      format.html do
        redirect_to :action => 'list'
      end
      format.js { render :nothing => true }
      format.xml { head 200 }
    end
  end
end
