myncd2 <- function(x = x,
                 tf = 0.5,
                 w = 3000,
                 ncores = 2,
                 minIS = 2,
                 by= "POS") {
        assertthat::assert_that(length(unique(x[, CHR])) == 1,
                                msg = "Run one chromosome at a time\n")
        x <- copy(x)
        x[, AF := tx_1 / tn_1]  #allele relative frequency
        x[, AF2 := tx_2 / tn_2]  #allele relative frequency
        x[, ID := seq_along(CHR)]
        w1 <- w / 2
        polpos <- x[AF != 1 & AF != 0]$ID #select positions that are polymorphic
        fdpos <- sort(c(x[AF == 1 & AF2 == 0]$ID, #fixed difference
                        x[AF == 0 & AF2 == 1]$ID)) #also fixed difference
        #to do: check that the there is no intersection between polpos and fdpos.
        x[, SNP := ifelse(ID %in% polpos, T, F)] #logical: True if SNP, False if not.
        x[, fd := ifelse(ID %in% fdpos, T, F)] #logical: True if FD, False if not.
        x[, MAF := ifelse(AF > 0.5, 1 - AF, AF)]
        x[, CHR := stringr::str_replace(stringr::str_replace(CHR,"-",""), ":","")]
        ####################################################################################
        if(by=="POS"){
                #windows (sliding)
                #to do: add some checks here
                vec<-data.table(start=seq(from=x$POS[1], to=x$POS[nrow(x)], by=w1))
                vec[,end:=start+w]
                setkey(vec, start, end)
        }else if (by=="IS"){
                #to do: write this code.
                vec<-data.table(start=x$POS-w1)
                vec[,end:=start+w]
                firstwin <- which.max(vec$start[vec$start<0])
                lastwin <- which.min(vec$end[vec$end>10000])
                vec$start[vec$start<0][firstwin] <- 1
                vec$end[vec$end>10000][lastwin] <- 10000
                vec <- vec[vec$start>=1 & vec$end<=10000,]
                setkey(vec, start, end)
        }
        x[,start:=POS][,end:=POS]
        res_0<-foverlaps(x, vec, type="within")[, Win.ID:=paste0(CHR,"_",start,"_",end)][,.(POS, ID,SNP,fd,MAF, Win.ID)]
        res_0<-res_0[SNP==T | fd==T][, tf:=tf]
        res_1<-unique(res_0[,.(POS=POS,
                               S = sum(SNP),
                               FD = sum(fd),
                               IS = sum(SNP) + sum(fd),
                               tf = tf),
                            by= Win.ID])

        setkey(res_0, Win.ID, POS, tf)
        setkey(res_1, Win.ID, POS, tf)
        res_2<- setorder(res_0[res_1], cols="POS")
        #to do: check that each Win.ID has the number of rows given by IS
        res_3<-res_2[, .(ncd2 = sqrt(sum((MAF-tf)^2)/IS)), by=Win.ID]
        res_3<-unique(res_3, by = "Win.ID")
        res_3b<-res_2[,.(POS,Win.ID,S, FD, IS,tf)]
        res_3b<-unique(res_3b, by="Win.ID")
        setkey(res_3, "Win.ID")
        setkey(res_3b, "Win.ID")
        res4 <- setorder(data.table::merge.data.table(res_3, res_3b)[IS>=minIS],cols="POS")[,POS:=NULL]
        return(res4)
}
