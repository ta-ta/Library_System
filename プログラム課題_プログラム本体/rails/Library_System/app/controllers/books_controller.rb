class BooksController < ApplicationController
    def index
    end

    def show
    	@books = Hash.new
        #表示内容の設定
        if params[:username] == 'all'#all指定
            @books = Book.all
        else#指定なし, urlから取得
            @books = Book.where(username: params[:username])
            if @books.length == 0 then#ヒットしない時はallと同じ
                @books = Book.all
            end
        end
    end
    
    def update
        if params[:book][:username] == '' && params[:book][:ISBN] == '' then#入力フォーム両方とも空欄, 全て表示するページへ遷移
            display_all_books
        elsif params[:book][:username] != '' && params[:book][:ISBN] == '' then#入力フォームユーザーネームのみ記入, ユーザーネームの貸し出し中の図書を表示するページへ遷移
            display_user_books
        elsif params[:book][:username] == '' && params[:book][:ISBN] != '' then#入力フォームISBNのみ記入, 新たに登録
            register_book
            display_all_books
        elsif params[:book][:username] != '' && params[:book][:ISBN] != '' then#入力フォーム両方とも記入, 貸し出し, 返却, 削除
            update_lend_return_delete
        end
    end
    
    
    
    #全て表示するページへ遷移
    def display_all_books
        redirect_to '/books/show/all'
    end
    
    ##ユーザーネームの貸し出し中の図書を表示するページへ遷移
    def display_user_books
        redirect_to '/books/show/'+params[:book][:username]
    end
    
    #図書の登録
    def register_book
        @resister_book = Book.new
        @resister_book.ISBN = params[:book][:ISBN]
        if Book.find_by(ISBN: @resister_book.ISBN) == nil then#未登録の場合のみ新たに登録
            @resister_book.title = ''
            @resister_book.username = ''
            @resister_book.save
        end
    end

    #図書の貸し出し, 返却, 削除
    def update_lend_return_delete
        @update_book = Book.find_by(ISBN: params[:book][:ISBN])
        if @update_book == nil then#未登録なら、ユーザーネームに貸し出し
            register_lend
            display_user_books
        else
            if params[:book][:username] == params[:book][:ISBN] then#削除処理
                delete_book
                display_all_books
            else
                if @update_book.username == '' then#貸し出し処理
                    lend_book
                elsif @update_book.username == params[:book][:username]#返却処理
                    return_book
                end
                display_user_books
            end
        end
    end

    #貸し出し
    def lend_book
        @update_book.username = params[:book][:username]
        @update_book.save
    end

    #返却
    def return_book
        @update_book.username = ''
        @update_book.save
    end

    #登録し、貸し出し
    def register_lend
        @resister_book = Book.new
        @resister_book.ISBN = params[:book][:ISBN]
        @resister_book.title = ''
        @resister_book.username = params[:book][:username]
        @resister_book.save
    end

    #削除
    def delete_book
        @update_book.destroy
    end

end