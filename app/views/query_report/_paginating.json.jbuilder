json.paginating do 
	pg = 1
	begin
		pg = params[:page]
	rescue
		pg = 1
    end
 	if pg != 0
		json.total_pages model.page(pg).total_pages
		json.current_page model.page(pg).current_page
		json.next_page model.page(pg).next_page
		json.prev_page model.page(pg).prev_page
		json.first_page? model.page(pg).first_page?
		json.last_page? model.page(pg).last_page?
		json.out_of_range? model.page(pg).out_of_range?
	end
end